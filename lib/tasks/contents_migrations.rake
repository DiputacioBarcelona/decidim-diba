# frozen_string_literal: true

namespace :populate_tasks do
  namespace :contents_migrations do
    desc "migrate space images to hero content blocks"
    task migrate_spaces_hero_blocks: [:environment] do
      migrate_spaces(Decidim::ParticipatoryProcess.all, "participatory_process_homepage", "banner_image")
      migrate_spaces(Decidim::Assembly.all, "assembly_homepage", "banner_image")
      migrate_spaces(Decidim::ParticipatoryProcessGroup.all, "participatory_process_group_homepage", "hero_image")
    end
  end
end

def migrate_spaces(spaces_list, scope_name, space_attachment_attribute)
  spaces_list.each do |space|
    hero_content_block = Decidim::ContentBlock.find_by(scope_name:, scoped_resource_id: space.id, manifest_name: "hero")
    hero_attachment = hero_content_block.attachments.find_by_name("background_image")
    next if hero_attachment.blank?
    next if hero_attachment.file.attached?
    next unless space.send(space_attachment_attribute).attached?

    space.send(space_attachment_attribute).blob.open { |_| }

    hero_attachment.file.attach(space.send(space_attachment_attribute).blob)
  rescue ActiveStorage::FileNotFoundError
    puts "Skipped due to errors accessing blob content..."
  end
end
