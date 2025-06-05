# frozen_string_literal: true

#
# Utils to remove remaining consultations data
#
namespace :consultations do
  desc "Removes resources like comments associated to deprecated consultations models"
  task remove_associated_resources: :environment do
    expression = "%consultations%"

    Decidim::Comments::Comment.where("decidim_commentable_type ILIKE ?", expression).each(&:delete)
    Decidim::Comments::Comment.where("decidim_root_commentable_type ILIKE ?", expression).each(&:delete)
    Decidim::ParticipatorySpaceLink.where("from_type ILIKE ?", expression).destroy_all
    Decidim::ParticipatorySpaceLink.where("to_type ILIKE ?", expression).destroy_all
    PaperTrail::Version.where("item_type ILIKE ?", expression).destroy_all
    Decidim::ResourceLink.where("to_type ILIKE ?", expression).destroy_all
    Decidim::ResourceLink.where("from_type ILIKE ?", expression).destroy_all
    Decidim::ResourcePermission.where("resource_type ILIKE ?", expression).destroy_all
    Decidim::Follow.where("decidim_followable_type ILIKE ?", expression).each(&:delete)
    Decidim::Attachment.where("attached_to_type ILIKE ?", expression).destroy_all
    Decidim::AttachmentCollection.where("collection_for_type ILIKE ?", expression).destroy_all
    action_log_sql_deletion_by_resource_type = "delete from decidim_action_logs where resource_type ILIKE '#{expression}'"
    action_log_sql_deletion_by_space_type = "delete from decidim_action_logs where participatory_space_type ILIKE '#{expression}'"
    ActiveRecord::Base.connection.execute(action_log_sql_deletion_by_resource_type)
    ActiveRecord::Base.connection.execute(action_log_sql_deletion_by_space_type)
    Decidim::Component.where("participatory_space_type ILIKE ?", expression).destroy_all
  end
end
