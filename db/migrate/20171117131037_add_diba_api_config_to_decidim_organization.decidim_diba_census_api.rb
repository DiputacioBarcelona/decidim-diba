# This migration comes from decidim_diba_census_api (originally 20171117130656)
class AddDibaApiConfigToDecidimOrganization < ActiveRecord::Migration[5.1]

  def change
    add_column :decidim_organizations, :diba_census_api_ine, :string
    add_column :decidim_organizations, :diba_census_api_username, :string
    add_column :decidim_organizations, :diba_census_api_password, :string
  end

end
