# This migration comes from decidim_diba_census_api (originally 20171115094751)
class AddHandlerToOrganizations < ActiveRecord::Migration[5.1]

  def change
    organizations = Decidim::Organization.all
    organizations.each do |org|
      org.available_authorizations << 'DibaCensusApiAuthorizationHandler'
      org.save
    end
  end

end
