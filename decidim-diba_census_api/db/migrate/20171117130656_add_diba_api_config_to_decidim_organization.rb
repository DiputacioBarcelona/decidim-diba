# frozen_string_literal: true

class AddDibaApiConfigToDecidimOrganization < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :diba_census_api_ine, :string
    add_column :decidim_organizations, :diba_census_api_username, :string
    add_column :decidim_organizations, :diba_census_api_password, :string
  end
end
