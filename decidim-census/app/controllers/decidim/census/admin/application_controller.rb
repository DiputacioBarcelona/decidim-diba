# frozen_string_literal: true

module Decidim
  module Census
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Features::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      # class ApplicationController < Decidim::Admin::Features::BaseController
      class ApplicationController < Decidim::Admin::ApplicationController
      end
    end
  end
end
