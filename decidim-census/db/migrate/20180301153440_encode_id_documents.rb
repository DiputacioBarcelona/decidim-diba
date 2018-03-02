class EncodeIdDocuments < ActiveRecord::Migration[5.1]

  def up
    Decidim::Census::CensusDatum.find_each do |census_datum|
      encoded_id_document = Digest::SHA256.hexdigest(
        "#{census_datum.id_document}-#{Rails.application.secrets.secret_key_base}"
      )
      census_datum.update(id_document: encoded_id_document)
    end
  end

end
