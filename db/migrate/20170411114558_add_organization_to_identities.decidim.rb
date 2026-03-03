# frozen_string_literal: true

# This migration comes from decidim (originally 20170405094028)
# This file has been modified by `decidim upgrade:migrations` task on 2026-02-05 12:06:52 UTC
class AddOrganizationToIdentities < ActiveRecord::Migration[5.0]
  def change
    add_reference :decidim_identities, :decidim_organization, index: true, foreign_key: true
  end
end
