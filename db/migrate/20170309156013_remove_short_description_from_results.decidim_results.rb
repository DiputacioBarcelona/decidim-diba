# This migration comes from decidim_results (originally 20170129164553)
class RemoveShortDescriptionFromResults < ActiveRecord::Migration[5.0]

  def change
    remove_column :decidim_results_results, :short_description
  end

end
