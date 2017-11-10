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
