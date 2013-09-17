require 'spec_helper'

describe TripDayPublisher do
  subject { TripDayPublisher.new 13677264000 }

  let!(:trip_day) { create :trip_day }

  its(:date) { should eql(13677264000) }

  describe 'find_trip_day' do
    before(:each) { @found_trip_day = subject.send(:find_trip_day) }
  
    it 'finds trip day by date' do
      @found_trip_day.should eql(trip_day)
    end
  end

  describe '#perform' do
    before(:each) { subject.perform }
    after(:each) { $redis.flushdb }

    it 'sets redis value to trip_day key' do
      $redis.get('trip_day').should eql('1_merged_416773')
    end

    it 'publishes trip_day' do
      $redis.should receive(:publish)
    end
  end
end
