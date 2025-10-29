# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ParticipatoryProcessHelperOverrides
      extend ActiveSupport::Concern

      included do
        def process_types
          @process_types ||= Decidim::ParticipatoryProcessType.joins(:processes).where(organization: current_organization).distinct
        end
      end
    end
  end
end
