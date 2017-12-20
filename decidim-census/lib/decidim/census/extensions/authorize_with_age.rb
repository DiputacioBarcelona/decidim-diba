module Decidim
  module Census
    module Extensions
      module AuthorizeWithAge
        # Handlers that requires AuthorizeWithAge authorization
        AGE_HANDLERS = %w[
          census_authorization_handler
          diba_census_api_authorization_handler
        ].freeze

        def authorize
          if authorization_handler_name.in?(AGE_HANDLERS)
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
          return unless authorization
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
