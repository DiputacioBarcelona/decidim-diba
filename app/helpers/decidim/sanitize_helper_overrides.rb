# frozen_string_literal: true

module Decidim
  module SanitizeHelperOverrides
    extend ActiveSupport::Concern

    included do
      def decidim_html_escape(text)
        ERB::Util.html_escape_once(text.to_str)
      end
    end
  end
end
