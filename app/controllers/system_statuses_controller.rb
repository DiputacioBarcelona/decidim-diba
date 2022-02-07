# frozen_string_literal: true

class SystemStatusesController < ApplicationController
  def show
    Decidim::Organization.count
    render plain: "ok"
  end
end
