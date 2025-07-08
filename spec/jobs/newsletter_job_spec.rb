# frozen_string_literal: true

require "rails_helper"

module Decidim
  module Admin
    describe NewsletterJob do
      let!(:newsletter) { create(:newsletter, organization:, total_deliveries: 0) }
      let!(:organization) { create(:organization) }
      let!(:another_organization) { create(:organization) }
      let!(:deliverable_user) { create(:user, :confirmed, newsletter_notifications_at: Time.current, organization:) }
      let!(:another_deliverable_user) { create(:user, :confirmed, newsletter_notifications_at: Time.current, organization: another_organization) }
      let!(:undeliverable_user) { create(:user, newsletter_notifications_at: Time.current, organization:) }
      let!(:non_deliverable_user) { create(:user, :confirmed, newsletter_notifications_at: nil, organization:) }
      let!(:deleted_user) { create(:user, :confirmed, :deleted, newsletter_notifications_at: Time.current, organization:) }
      let(:send_to_all_users) { true }
      let(:send_to_followers) { false }
      let(:send_to_participants) { false }
      let(:send_to_selected_users) { false }
      let(:participatory_space_types) { [] }
      let(:scope_ids) { [] }
      let(:selected_users_ids) { [] }

      let(:form_params) do
        {
          send_to_all_users:,
          send_to_followers:,
          send_to_participants:,
          participatory_space_types:,
          send_to_selected_users:,
          scope_ids:,
          selected_users_ids:
        }
      end

      let(:form) do
        SelectiveNewsletterForm.from_params(
          form_params
        ).with_context(
          current_organization: organization
        )
      end

      let!(:recipients_ids) { [deliverable_user.id] }

      it "delivers a newsletter to a the eligible users" do
        expect(NewsletterDeliveryJob).to receive(:perform_later).with(deliverable_user, newsletter)
        expect(NewsletterDeliveryJob).not_to receive(:perform_later).with(undeliverable_user, newsletter)

        NewsletterJob.perform_now(newsletter, form.as_json, recipients_ids)
      end

      it "updates the recipients count" do
        NewsletterJob.perform_now(newsletter, form.as_json, recipients_ids)
        expect(newsletter.reload.total_recipients).to eq(1)
      end

      it "updates the deliveries count" do
        NewsletterJob.perform_now(newsletter, form.as_json, recipients_ids)
        expect(newsletter.reload.total_deliveries).to eq(0)
      end

      it "updates the extended data excluding the send_to_selected_users attribute" do
        NewsletterJob.perform_now(newsletter, form.as_json, recipients_ids)
        expect(newsletter.reload.extended_data).to eq(
          "send_to_all_users" => true,
          "send_to_followers" => false,
          "send_to_participants" => false,
          "participatory_space_types" => [],
          "scope_ids" => []
        )
      end

      context "when send_to_selected_users is enabled" do
        let(:send_to_selected_users) { true }

        it "updates the extended data including the selected_users attributes" do
          NewsletterJob.perform_now(newsletter, form.as_json, recipients_ids)
          expect(newsletter.reload.extended_data).to eq(
            "send_to_all_users" => true,
            "send_to_followers" => false,
            "send_to_participants" => false,
            "send_to_selected_users" => true,
            "participatory_space_types" => [],
            "scope_ids" => [],
            "selected_users_ids" => []
          )
        end
      end
    end
  end
end
