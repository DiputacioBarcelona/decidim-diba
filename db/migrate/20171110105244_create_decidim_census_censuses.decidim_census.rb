# This migration comes from decidim_census (originally 20171110102910)
class CreateDecidimCensusCensuses < ActiveRecord::Migration[5.1]

  def change
    create_table :decidim_census_censuses do |t|
      t.string :id_document
      t.date :birthdate
      t.datetime 'created_at', null: false
    end
  end

end