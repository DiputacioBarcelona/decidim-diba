# frozen_string_literal: true

class NewsletterSettingsController < Decidim::Admin::ApplicationController
  def show
    enforce_permission_to :index, :newsletter

    newsletter = Decidim::Newsletter.where(organization: current_organization).find_by(id: params[:newsletter_id])

    render json: { message: selected_users(newsletter), status: 200 }
  end

  private

  def current_organization
    current_user.organization
  end

  def selected_users(newsletter)
    return [] if newsletter.blank? || newsletter.extended_data["selected_users_ids"].blank?

    newsletter.extended_data["selected_users_ids"].compact_blank
  end
end
