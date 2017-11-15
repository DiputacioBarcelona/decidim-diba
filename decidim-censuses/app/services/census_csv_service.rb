module CensusCsvService
  
  def self.load(file)
    values = []
    errors = 0
    CSV.foreach(file, headers: true, col_sep: ';') do |row|
      id_document = normalize_id_document(row[0])
      date = normalize_date(row[1])
      if !id_document.empty? && !date.nil?
        values << [id_document, date]
      else
        errors += 1
      end
    end
    { values: values, error_count: errors }
  end

  def self.normalize_id_document(string)
    (string || '').gsub(/[^A-z0-9]/, '').upcase
  end

  def self.normalize_date(string)
    Date.strptime((string || '').strip, '%d/%m/%Y').strftime('%Y/%m/%d')
  rescue StandardError
    nil
  end

end
