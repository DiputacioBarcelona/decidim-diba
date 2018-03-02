module Decidim
  module Census
    class CensusDatum < ApplicationRecord

      belongs_to :organization, foreign_key: :decidim_organization_id,
                                class_name: 'Decidim::Organization'

      # An organzation scope
      def self.inside(organization)
        where(decidim_organization_id: organization.id)
      end

      # Search for a specific document id inside a organization
      def self.search_id_document(organization, id_document)
        CensusDatum.inside(organization)
                   .where(id_document: normalize_and_encode_id_document(id_document))
                   .order(created_at: :desc, id: :desc)
                   .first
      end

      # Normalizes a id document string (remove invalid characters) and encode it
      # to conform with Decidim privacy guidelines.
      def self.normalize_and_encode_id_document(id_document)
        return '' unless id_document
        id_document = id_document.gsub(/[^A-z0-9]/, '').upcase
        return '' if id_document.blank?
        Digest::SHA256.hexdigest(
          "#{id_document}-#{Rails.application.secrets.secret_key_base}"
        )
      end

      # Convert a date from string to a Date object
      def self.parse_date(string)
        Date.strptime((string || '').strip, '%d/%m/%Y')
      rescue StandardError
        nil
      end

      # Insert a collectiojn of values
      def self.insert_all(organization, values)
        table_name = CensusDatum.table_name
        columns = %w[id_document birthdate decidim_organization_id created_at].join(',')
        now = Time.current
        values = values.map do |row|
          "('#{row[0]}', '#{row[1]}', '#{organization.id}', '#{now}')"
        end
        sql = "INSERT INTO #{table_name} (#{columns}) VALUES #{values.join(',')}"
        ActiveRecord::Base.connection.execute(sql)
      end

      # Clear all census data for a given organization
      def self.clear(organization)
        CensusDatum.inside(organization).delete_all
      end

    end
  end
end
