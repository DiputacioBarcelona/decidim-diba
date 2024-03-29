# frozen_string_literal: true

class NewsletterSettingsController < ApplicationController
  def show
    user = Decidim::User.find_by(id: params[:user_id], organization: current_organization)

    if user.newsletter_notifications_at.present?
      render json: { message: "ok", status: 200 }
    else
      render json: { message: t(".user_without_newsletter_settings"), status: 403 }
    end
  end

  private

  def current_organization
    current_user.organization
  end
end
