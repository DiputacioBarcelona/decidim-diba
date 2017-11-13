module AuthorizeWithAge
  def authorize
    if authorization_handler_name == 'census_authorization_handler'
      authorize_with_age
    else
      super
    end
  end

  private

  def authorize_with_age
    return status(:missing) unless valid_metadata?
    return status(:invalid, fields: [:birthdate]) if current_age < minimum_age
    status(:ok)
  end

  def valid_metadata?
    !authorization.metadata['birthdate'].nil?
  end

  def birthdate
    @birthdate ||= Date.strptime(authorization.metadata['birthdate'], '%Y/%m/%d')
  end

  def current_age
    now = Date.current
    extra_year = (now.month > birthdate.month) || (
      now.month == birthdate.month && now.day >= birthdate.day
    )
    now.year - birthdate.year - (extra_year ? 0 : 1)
  end

  def minimum_age
    @minimum_age ||= begin
      Integer(permission_options['edad'].to_s, 10)
    rescue ArgumentError
      18
    end
    @minimum_age
  end
end
