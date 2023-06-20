# frozen_string_literal: true

module Decidim
  module Census
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
