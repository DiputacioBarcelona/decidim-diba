# frozen_string_literal: true

require "csv"
require "faker"

CSV.open("example.csv", "wb", col_sep: ";") do |csv|
  csv << ["DNI", "Data (mm/dd/aaaa)"]
  1.upto(50 * 1000) do
    dni = Faker::Number.number(digits: 8)
    date = Faker::Date.birthday(min_age: 10, max_age: 80).strftime("%d/%m/%Y")
    csv << [dni, date]
  end
end
