# frozen_string_literal: true

require "spec_helper"

# Verifies the decorator prepended to
# Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess: creating a
# participatory process automatically adds the process_settings component.
module Decidim
  module ProcessSettings
    describe "CreateParticipatoryProcess adds the process_settings component" do
      subject { Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.new(form) }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, organization:) }
      let(:errors) { double.as_null_object }
      let(:attributes) do
        {
          title: { en: "title" },
          subtitle: { en: "subtitle" },
          slug: "process-slug",
          hashtag: "hashtag",
          meta_scope: { en: "meta scope" },
          hero_image: nil,
          promoted: nil,
          developer_group: { en: "developer group" },
          local_area: { en: "local" },
          target: { en: "target" },
          participatory_scope: { en: "participatory scope" },
          participatory_structure: { en: "participatory structure" },
          start_date: nil,
          end_date: nil,
          description: { en: "description" },
          short_description: { en: "short_description" },
          private_space: false,
          taxonomizations: [],
          errors:,
          weight: 1,
          related_process_ids: [],
          participatory_process_group: nil,
          announcement: { en: "message" }
        }
      end
      let(:form) do
        instance_double(
          Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm,
          **attributes,
          invalid?: false,
          current_user:,
          current_organization: organization,
          organization:
        )
      end

      let(:created_process) { Decidim::ParticipatoryProcess.last }

      it "adds a process_settings component to the created process" do
        expect { subject.call }.to change(Decidim::ParticipatoryProcess, :count).by(1)

        component = created_process.components.find_by(manifest_name: "process_settings")
        expect(component).to be_present
      end

      it "leaves the automatic_step_change setting disabled" do
        subject.call

        component = created_process.components.find_by(manifest_name: "process_settings")
        expect(component.settings.automatic_step_change).to be(false)
      end
    end
  end
end
