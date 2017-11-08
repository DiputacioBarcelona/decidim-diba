class CreateCensuses < ActiveRecord::Migration[5.1]
  def change
    create_table :censuses do |t|
      t.string :id_document
      t.date :birthdate
      t.timestamps
    end
  end
end
