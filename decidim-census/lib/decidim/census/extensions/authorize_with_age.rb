module Decidim
  module Census
    module Extensions
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
          return status(:invalid, fields: [:birthdate]) unless valid_age?
          status(:ok)
        end

        def valid_metadata?
          !authorization.metadata['birthdate'].nil?
        end

        def valid_age?
          (birthdate + minimum_age.years) <= Date.current
        end

        def birthdate
          @birthdate ||= Date.strptime(authorization.metadata['birthdate'], '%Y/%m/%d')
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
    end
  end
end
