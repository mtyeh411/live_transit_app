require 'spec_helper'

describe Gtfsr::VehiclePosition do
  subject { Gtfsr::VehiclePosition.new @vehicle_position }

  let(:gtfs_feed) {  "#{Rails.root}/spec/test_data/gtfsr_sample.pb" }
  let!(:stop_time) { create :stop_time }
  let!(:trip) { create :trip }
  let!(:stop) { create :stop }

  before(:all) {
    feed = TransitRealtime::FeedMessage.parse(File.read gtfs_feed)
    vehicle_positions = feed.entity.select do |e| e.has_vehicle? end
    @vehicle_position = vehicle_positions.first
  }

  its(:id) { should eq("vehicle_position_5366") }
  its(:timestamp) { should eq(1376051906) }

  its(:trip_id) { should eq("399785")}
  its(:stop_id) { should eq("") }
  its(:vehicle_id) { should eq("5366") }

  its(:lat) { should eq(38.96184539794922) }
  its(:lon) { should eq(-77.08500671386719) }
  its(:bearing) { should eq(120.0) }
  its(:odometer) { should eq(0.0) }
  its(:speed) { should eq(0.0) }

  it 'should retrieve the correct trip' do
    trip.trip_id.should eq(399785)
    trip.route_id.should eq(2640)
    trip.trip_headsign.should eq('Friendship Heights')
  end

#  its(:lat) { should be_kind_of(BigDecimal) }
#  its(:lon) { should be_kind_of(BigDecimal) }
#  its(:bearing) { should be_kind_of(BigDecimal) }
#  its(:odometer) { should be_kind_of(BigDecimal) }
#  its(:speed) { should be_kind_of(BigDecimal) }
#
#  its(:lat) { should be_within(90).of(0) }
#  its(:lon) { should be_within(180).of(0) }
#
#  it { should validate_numericality_of(:lat).is_greater_than_or_equal_to(-90).is_less_than_or_equal_to(90) }
#  it { should validate_numericality_of(:lon).is_greater_than_or_equal_to(-180).is_less_than_or_equal_to(180) }
#  it { should validate_numericality_of(:bearing).is_less_than(360) }
#  it { should validate_numericality_of(:odometer).is_less_than(1000000) }
#  it { should validate_numericality_of(:speed).is_less_than(100) }

end
