# frozen_string_literal: true

#
# A set of utils to manage DiBa organizations.
#
namespace :diba do
  desc "Finds information about the Organization or Organizations searching by the :host_term argument. Set :full (second param) to true for full information"
  task :org_by_host_like, [:host_term, :full] => :environment do |_task, args|
    query = Decidim::Organization.where("host ilike ?", "%#{args.host_term}%")
    puts "Found #{query.count} organizations"
    query.find_each do |org|
      puts ">>> Organization [#{org.id}] #{org.name}:"
      if args.full == "true"
        puts org.attributes.to_yaml
      else
        # rubocop: disable Metrics/LineLength
        puts "host: #{org.host}, time_zone: #{org.time_zone}, locales: #{org.default_locale} + [#{org.available_locales&.join(", ")}], available authorizations: [#{org.available_authorizations&.join(", ")}]"
        # rubocop: enable Metrics/LineLength
      end
    end
  end
end
