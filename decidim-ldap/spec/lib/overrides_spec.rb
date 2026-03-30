# frozen_string_literal: true

require "spec_helper"

# We check the checksum of the file overriden.
# If the test fails, that the overriden file should be updated.
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/views/decidim/devise/sessions/new.html.erb" => "da0d18178c8dcead2774956e989527c5",
      "/app/views/decidim/shared/_login_modal.html.erb" => "98bd2832be207d7abcd48d2a0ba40bd0"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])
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
