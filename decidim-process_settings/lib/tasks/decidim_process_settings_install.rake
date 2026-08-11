# frozen_string_literal: true

namespace :decidim_process_settings do
  desc "Adds the process_settings component (first position, option disabled) to every participatory process, published or not"
  task install: :environment do
    created = 0

    Decidim::ParticipatoryProcess.find_each do |process|
      component = Decidim::ProcessSettings::ComponentCreator.create_for(process)

      next unless component.previously_new_record?

      created += 1
      puts "Participatory process ##{process.id}: added process_settings component ##{component.id}"
    end

    puts "Done. Added the component to #{created} participatory process(es)."
  end
end
