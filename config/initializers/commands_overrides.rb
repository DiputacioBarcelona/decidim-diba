# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Meetings::Admin::CopyMeeting.prepend(Decidim::Meetings::Admin::CopyMeetingOverrides)
end
