# frozen_string_literal: true

module Decidim
  module Census
    # Census have no public app (see AdminEngine)
    class Engine < ::Rails::Engine

      isolate_namespace Decidim::Census

      initializer 'decidim_admin.inject_abilities_to_user' do |_app|
        Decidim.configure do |config|
          config.admin_abilities += [
            'Decidim::Census::Abilities::AdminAbility'
          ]
        end
      end

      ActiveSupport::Inflector.inflections(:en) do |inflect|
        inflect.irregular 'census', 'censuses'
      end

    end
  end
end
