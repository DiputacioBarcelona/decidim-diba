# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Census::SubcensusDocument do
  it { expect(build(:subcensus_document)).to be_valid }
  it { expect(build(:subcensus_document, id_document: nil)).not_to be_valid }
  it { expect(build(:subcensus_document, subcensus: nil)).not_to be_valid }
end
