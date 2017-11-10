# frozen_string_literal: true

module Decidim
  module Census
    # Census have no public app (see AdminEngine)
    class Engine < ::Rails::Engine

      isolate_namespace Decidim::Census

      ActiveSupport::Inflector.inflections(:en) do |inflect|
        inflect.irregular 'census', 'censuses'
      end

    end
  end
end
