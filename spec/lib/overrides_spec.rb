# frozen_string_literal: true

require "spec_helper"

# We check the checksum of the file overriden.
# If the test fails, that the overriden file should be updated.
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/cells/decidim/newsletter_templates/basic_only_text/show.erb" => "6f85f6b733a6db3b11f9cabb19ae4126",
      "/app/cells/decidim/newsletter_templates/basic_only_text_settings_form/show.erb" => "cc8e26ddc53c0b65eddf472ed4c5614e",
      "/app/cells/decidim/newsletter_templates/image_text_cta/show.erb" => "606f899f03d5e4e6d3c1691132eeb2ac"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    # rubocop:disable Rails/DynamicFindBy
    spec = ::Gem::Specification.find_by_name(item[:package])
    # rubocop:enable Rails/DynamicFindBy
    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
