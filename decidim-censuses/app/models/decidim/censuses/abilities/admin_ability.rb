# frozen_string_literal: true

module Decidim
  module Censuses
    module Abilities
      # Defines the abilities related to surveys for a logged in admin user.
      # Intended to be used with `cancancan`.
      class AdminAbility < Decidim::Abilities::AdminAbility

        def define_abilities
          super
          can :manage, Decidim::Censuses::Census
        end

      end
    end
  end
end
