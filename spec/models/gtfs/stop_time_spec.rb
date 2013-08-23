require 'spec_helper'

describe Gtfs::StopTime do
  it { should belong_to(:trip) }
  it { should belong_to(:stop) }
end
