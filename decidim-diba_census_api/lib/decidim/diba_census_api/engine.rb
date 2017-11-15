# frozen_string_literal: true

require 'rails'
require 'active_support/all'

require 'decidim/core'

module Decidim
  module DibaCensusApi
    class Engine < ::Rails::Engine

      isolate_namespace Decidim::DibaCensusApi

    end
  end
end
