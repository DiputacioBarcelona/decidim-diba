require 'csv'

class Census < ApplicationRecord

  def self.last_import_at
    last = Census.order(created_at: :desc).first
    last ? last.created_at : nil
  end

  def self.import(file)
    Census.delete_all
    CSV.foreach(file, headers: true) do |row|
      dni = row[0].strip
      date = Date.strptime(row[1].strip, '%d/%m/%Y')
      Census.create!(id_document: dni, birthdate: date)
    end
  end

end
