require 'spec_helper'

describe Gtfs::Stop do
  it { should have_many(:stop_times) }
  it { should have_many(:trips).through(:stop_times) }
  it { should have_many(:routes).through(:trips) }
end
