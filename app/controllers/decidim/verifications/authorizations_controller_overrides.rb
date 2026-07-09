# frozen_string_literal: true

module Decidim
  module Verifications
    # Overrides Decidim::Verifications::AuthorizationsController to fix the
    # ephemeral session transfer losing the current pending onboarding action.
    #
    # When an ephemeral user verifies with credentials that already belong to
    # another ephemeral user (same `unique_id`), the session is transferred to
    # that existing user (see Decidim::Verifications::AuthorizeUser). The
    # existing user, however, keeps its own (stale) pending onboarding action in
    # `extended_data`, so after the transfer the visitor is redirected to that
    # old action (e.g. a survey already answered) instead of the action they
    # were trying to complete (e.g. voting a budget).
    #
    # This override carries the pending onboarding action from the current
    # session onto the transferred user before signing them in.
    #
    # Prepended (not included) because it redefines the existing #create action.
    module AuthorizationsControllerOverrides
      def create
        AuthorizeUser.call(handler, current_organization) do
          on(:ok) do
            flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications")
            redirect_to redirect_url || authorizations_path
          end

          on(:transferred) do |transfer|
            message = t("authorizations.create.success", scope: "decidim.verifications")
            if transfer.records.any?
              flash[:html_safe] = true
              message = <<~HTML
                <p>#{CGI.escapeHTML(message)}</p>
                <p>#{CGI.escapeHTML(t("authorizations.create.transferred", scope: "decidim.verifications"))}</p>
                #{transfer.presenter.records_list_html}
              HTML
            end

            flash[:notice] = message
            redirect_to redirect_url || authorizations_path
          end

          on(:transfer_user) do |authorized_user|
            transfer_onboarding_action(current_user, authorized_user)
            authorized_user.update(last_sign_in_at: Time.current, deleted_at: nil)
            sign_out(current_user)
            sign_in(authorized_user)

            redirect_to decidim_verifications.onboarding_pending_authorizations_path
          end

          on(:invalid) do
            flash[:alert] = t("authorizations.create.error", scope: "decidim.verifications")
            render action: :new
          end
        end
      end

      private

      # Preserves the pending onboarding action of the transferring session on
      # the user that takes over it, so the onboarding flow resumes the action
      # the visitor was trying to complete (e.g. voting a budget) instead of the
      # transferred user's stale action (e.g. a survey already answered).
      def transfer_onboarding_action(from_user, to_user)
        pending_action = from_user.extended_data[Decidim::OnboardingManager::DATA_KEY]
        return if pending_action.blank?

        to_user.update!(
          extended_data: to_user.extended_data.merge(Decidim::OnboardingManager::DATA_KEY => pending_action)
        )
      end
    end
  end
end
