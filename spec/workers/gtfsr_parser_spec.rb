require 'spec_helper'

describe GtfsrParser do
  let(:gtfs_feed) {  File.read(Rails.root.to_s + '/spec/samples/gtfsr_sample.pb') }

  describe 'manages job queue' do
    before(:each) { 
      GtfsrParser.perform_async('http://www.a.com') 
    }
    
    it 'pushes job' do
      expect(GtfsrParser).to have_enqueued_jobs(1)
    end

    it 'clears queue' do
      GtfsrParser.clear
      GtfsrParser.jobs.should have(0).jobs
    end
  end

  it { should allow_value('http://www.good-example.com').for(:uri) }
  it { should_not allow_value('123').for(:uri) }

  describe '#perform' do
    context 'when given a valid uri' do
      let(:feed) { subject.send(:parse, 'http://www.good-example.com') }

      before(:each) { 
        response = double("Net::HTTPResponse")
        response.stub(:code) { 200 }
        response.stub(:message) { 'OK' }
        response.stub(:body) { gtfs_feed }
        Net::HTTP.stub(:get_response) { response } 

        $redis.flushdb
      }

      after(:all) { $redis.flushdb }

      it 'parses feed' do
        feed.entity.length.should eql(455)
      end

      it 'selects vehicle position updates' do
        subject.send(:select, feed, 'vehicle').should have(228).item
     end

      it 'publishes to gtfsr update queues' do
        subject.send(:publish, feed)
        $redis.should_receive(:publish)
      end

      context 'with persisted stoptimes' do
        let!(:stop_time) { create :stop_time, trip_id:416601 }
        let!(:trip) { create :trip, id:416601 }
        let!(:stop) { create :stop }

        it 'stores vehicle timestamps by vehicle_position id' do
          subject.send(:publish, feed)
          vehicle_event_timestamps = $redis.keys.flat_map { |k| k.scan /vehicle_position_\d/ }
          vehicle_event_timestamps.should have(1).items
        end

        it 'publishes to queue just for that stop' do
          subject.send(:publish, feed)
        end
      end
    end

    context 'when given an unresponsive uri' do
      before(:each) { 
        response = double("Net::HTTPResponse")
        response.stub(:code) { 404 }
        Net::HTTP.stub(:get_response) { response } 
      }

      it 'returns nothing' do
        feed = subject.send(:parse, 'http://www.bad-example.com')
        feed.should be_nil
      end

    end
  end
end
