require 'net/http'

class GtfsrParser
  include ActiveModel::Validations
  include Sidekiq::Worker
  sidekiq_options :queue => :sidekiq

  attr_accessor :uri
  validates_format_of :uri, :with => URI::regexp

  def perform(uri)
    feed = parse uri
    publish feed
  end

  private
  def parse(uri)
    response = Net::HTTP.get_response(URI(uri))
    if response.code == 200
      TransitRealtime::FeedMessage.parse(response.body)
    end
  end

  def select(feed, type) 
    feed.entity.select do |e|
      e.send("has_#{type}?")
    end
  end

  def publish(feed)
    %w[vehicle].each do |type|
      results = select(feed, type)

      results.each do |result|
        begin
          last_event_timestamp = $redis.get result.id
          last_event_timestamp ||= 0
          current_event_timestamp = result.send(type).timestamp

          if last_event_timestamp < current_event_timestamp
            payload = Rabl.render(result, "gtfsr/#{type}/show", :view_path=>'app/views', :format=>:json)
            trip = Trip.find(result.vehicle.trip.trip_id)
            stops = Trip.find(result.vehicle.trip.trip_id).stops.all if trip

            $redis.pipelined do
              $redis.publish("gtfsr/#{type}_updates", payload)
              $redis.set result.id, current_event_timestamp
              stops.each do |stop|
                $redis.publish("gtfsr/#{stop.id}/#{type}_updates", payload)
              end
            end
          end
        rescue
          next
        end
      end
    end
  end

end
