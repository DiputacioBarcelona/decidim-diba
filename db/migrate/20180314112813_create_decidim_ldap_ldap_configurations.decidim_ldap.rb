# This migration comes from decidim_ldap (originally 20180228081039)
class CreateDecidimLdapLdapConfigurations < ActiveRecord::Migration[5.1]

  def change
    create_table :decidim_ldap_configurations do |t|
      t.references :organization
      t.string :host
      t.string :port
      t.string :dn
      t.string :authentication_query
      t.string :username_field
      t.string :email_field
      t.string :password_field
      t.string :name_field

      t.timestamps
    end
  end

end
