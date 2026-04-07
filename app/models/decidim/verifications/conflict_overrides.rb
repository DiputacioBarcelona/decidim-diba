# frozen_string_literal: true

module Decidim
  module Verifications
    module ConflictOverrides
      extend ActiveSupport::Concern

      included do
        def can_participate?(_user)
          false
        end
      end
    end
  end
end
