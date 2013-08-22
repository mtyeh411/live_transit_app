require 'spec_helper'

describe VehiclePosition do
  subject { build(:vehicle_position) }

  describe 'corresponds to GTFS-R Position' do
    its(:lat) { should be_kind_of(BigDecimal) }
    its(:lon) { should be_kind_of(BigDecimal) }
    its(:bearing) { should be_kind_of(BigDecimal) }
    its(:odometer) { should be_kind_of(BigDecimal) }
    its(:speed) { should be_kind_of(BigDecimal) }
    
    its(:lat) { should be_within(90).of(0) }
    its(:lon) { should be_within(180).of(0) }

    it { should validate_numericality_of(:lat).is_greater_than_or_equal_to(-90).is_less_than_or_equal_to(90) }
    it { should validate_numericality_of(:lat).is_greater_than_or_equal_to(-180).is_less_than_or_equal_to(180) }
    it { should validate_numericality_of(:bearing).is_less_than(360) }
    it { should validate_numericality_of(:odometer).is_less_than(1000000) }
    it { should validate_numericality_of(:speed).is_less_than(100) }
  end

  describe 'corresponds to GTFS-R VehiclePosition' do
    its(:timestamp) { should be_kind_of(Time) }
    it { should belong_to(:trip) }
    it { should belong_to(:vehicle) }
    it { should have_many(:stops).through(:trip) }
  end

  it 'represent geometry in geojson' do
    geojson_hash = { 
      :type=>"Point",
      :coordinates=>[subject.lon, subject.lat]
    }
    subject.geometry.should eql(geojson_hash)
  end
end
