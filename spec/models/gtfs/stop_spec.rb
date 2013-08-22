require 'spec_helper'

describe Stop do
  it { should have_many(:stop_times) }
  it { should have_many(:trips).through(:stop_times) }
end
