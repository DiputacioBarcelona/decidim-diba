class CreateDecidimCensusCensuses < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_census_censuses do |t|

      t.timestamps
    end
  end
end
