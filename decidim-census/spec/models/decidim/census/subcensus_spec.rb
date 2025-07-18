# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Census::Subcensus do
  it { expect(build(:subcensus)).to be_valid }
  it { expect(build(:subcensus, participatory_process: nil)).not_to be_valid }
  it { expect(build(:subcensus, name: nil)).not_to be_valid }
end
