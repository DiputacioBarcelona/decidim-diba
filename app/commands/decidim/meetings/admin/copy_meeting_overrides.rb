# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Overrides Decidim::Meetings::Admin::CopyMeeting so that copying a meeting
      # with taxonomies does not crash.
      #
      # Upstream 0.30 passes `taxonomies: form.taxonomies` to the new meeting, but
      # the form attribute is an Array[Integer] of ids (with a `nil` coming from the
      # blank option of the select) while `Meeting#taxonomies` is a `has_many
      # :through` expecting Decidim::Taxonomy records, so the command raises
      # ActiveRecord::AssociationTypeMismatch. It is fixed upstream by
      # decidim/decidim#15736 (issue #15718), released in 0.32 and backported to
      # 0.31 (#15745) but labelled `no-backport` for 0.30.
      #
      # The only change from upstream is using `taxonomizations:
      # form.taxonomizations`, as CreateMeeting and UpdateMeeting already do.
      #
      # The whole method is reimplemented, so it is checksum-tracked in
      # spec/lib/overrides_spec.rb. Remove this override when upgrading to 0.31+.
      module CopyMeetingOverrides
        private

        def copy_meeting!
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: meeting.organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: meeting.organization).rewrite

          @copied_meeting = Decidim.traceability.create!(
            Meeting,
            form.current_user,
            taxonomizations: form.taxonomizations,
            title: parsed_title,
            description: parsed_description,
            end_time: form.end_time,
            start_time: form.start_time,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            location: form.location,
            location_hints: form.location_hints,
            component: meeting.component,
            private_meeting: form.private_meeting,
            transparent: form.transparent,
            author: form.current_organization,
            questionnaire: form.questionnaire,
            online_meeting_url: form.online_meeting_url,
            type_of_meeting: form.type_of_meeting,
            iframe_embed_type: form.iframe_embed_type,
            iframe_access_level: form.iframe_access_level,
            comments_enabled: form.comments_enabled,
            comments_start_time: form.comments_start_time,
            comments_end_time: form.comments_end_time,
            registration_type: form.registration_type,
            registration_url: form.registration_url,
            **fields_from_meeting
          )
        end
      end
    end
  end
end
