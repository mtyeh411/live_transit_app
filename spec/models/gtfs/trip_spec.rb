require 'spec_helper'

describe Gtfs::Trip do
  it { should have_many(:stop_times) }
  it { should have_many(:stops).through(:stop_times) }
end
