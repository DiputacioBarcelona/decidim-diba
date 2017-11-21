module Decidim
  module Census
    class CensusDatum < ApplicationRecord

      belongs_to :organization, foreign_key: :decidim_organization_id, class_name: 'Decidim::Organization'

      # An organzation scope
      def self.inside(organization)
        where(decidim_organization_id: organization.id)
      end

      # Search for a specific document id inside a organization
      def self.search_id_document(organization, id_document)
        CensusDatum.inside(organization)
                   .where(id_document: normalize_id_document(id_document))
                   .order(created_at: :desc, id: :desc)
                   .first
      end

      # Normalizes a id document string (remove invalid characters)
      def self.normalize_id_document(string)
        return '' unless string
        string.gsub(/[^A-z0-9]/, '').upcase
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
        values = values.map { |row| "('#{row[0]}', '#{row[1]}', '#{organization.id}', '#{now}')" }
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
