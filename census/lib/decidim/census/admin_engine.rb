# frozen_string_literal: true

module Decidim
  module Census
    # Census only
    class AdminEngine < ::Rails::Engine

      isolate_namespace Decidim::Census::Admin

      routes do
        resource :census_uploads, only: %i(show create)
      end

    end
  end
end
