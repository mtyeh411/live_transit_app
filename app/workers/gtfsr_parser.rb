require 'net/http'

class GtfsrParser
  include ActiveModel::Validations
  include Sidekiq::Worker
  sidekiq_options :queue => :gtfsr_parsers, :backtrace => true

  attr_accessor :uri
  validates_format_of :uri, :with => URI::regexp
  
  def logger
    @@logger ||= Logger.new("#{Rails.root}/log/parser.log")
  end

  def perform(uri, agency)
    feed = parse uri
    last_gtfsr_timestamp = get_redis_key agency, 0
    if feed.header.timestamp > last_gtfsr_timestamp.to_i
      publish feed, agency
    else
      logger.info("skipping feed from #{agency} dated #{feed.header.timestamp}: last published feed #{last_gtfsr_timestamp}")
    end
  end

  private
  def get_redis_key(key, default_value)
    value = $redis.get key
    value ||= default_value  
  end

  def parse(uri)
    response = Net::HTTP.get_response(URI(uri))
    TransitRealtime::FeedMessage.parse(response.body) if response.code == "200"
  end

  def select(feed, type) 
    feed.entity.select do |e|
      e.send("has_#{type}?")
    end
  end

  def publish(feed, agency)
    $redis.set agency, feed.header.timestamp

    %w[vehicle].each do |type|
      results = select(feed, type)

      results.each do |result|
        begin
          last_event_timestamp = get_redis_key result.id, 0
          current_event_timestamp = result.send(type).timestamp

          if last_event_timestamp.to_i < current_event_timestamp
            payload = Rabl.render(result, "geojson/#{type}/show", :view_path=>'app/views', :format=>:json)
            trip = Gtfs::Trip.includes(:stops).find_by_trip_id(result.vehicle.trip.trip_id)

            $redis.pipelined do
              $redis.publish("gtfsr/#{type}_updates", payload)
              $redis.set result.id, current_event_timestamp
              trip.stops.each do |stop|
                $redis.publish("gtfsr/#{stop.stop_code}/#{type}_updates", payload)
              end
            end
          end
        rescue Exception => e
          logger.error e.message
          next
        end
      end
    end
  end

end
