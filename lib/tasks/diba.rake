# frozen_string_literal: true

#
# A set of utils to manage DiBa organizations.
#
namespace :diba do
  desc "Finds information about the Organization, or Organizations, searching by the :host_term argument. Set :full (second param) to true for full information"
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

  desc "add an extension or content type to all organizations in file_upload_settings"
  task :update_file_upload_settings, [:configuration_hash] => [:environment] do |_t, args|
    raise "Please, provide a configuration hash in JSON format" if args[:configuration_hash].blank?

    # Provide argument in JSON format. Don't forget to escape commas with \, . Example:
    # rubocop: disable Metrics/LineLength
    # rails diba:update_file_upload_settings['{"allowed_content_types": {"admin": ["text/plain"]\, "default": ["text/plain"]}\, "allowed_file_extensions": {"admin": ["csv"]\, "default": ["csv"]\}}']
    # rubocop: enable Metrics/LineLength

    configuration_hash = JSON.parse(args[:configuration_hash])

    configuration_hash = configuration_hash.slice("allowed_content_types", "allowed_file_extensions").transform_values do |conf|
      conf.slice("admin", "default")
    end

    raise "Invalid format, provide an array for each final value" unless configuration_hash.values.all? { |v| v.values.all? { |u| u.is_a?(Array) } }

    Decidim::Organization.all.each do |organization|
      puts "\n\nReviewing rganization with host #{organization.host}..."

      organization_settings = organization.file_upload_settings

      if organization_settings.blank?
        puts "Organization settings blank. Skipping..."
        next
      end

      new_settings = configuration_hash.each_with_object({}) do |(k1, v1), hsh1|
        hsh1[k1] = v1.each_with_object({}) do |(k2, v2), hsh2|
          hsh2[k2] = ((organization_settings.dig(k1, k2) || []) + v2).uniq
        end
      end

      new_organization_settings = organization_settings.deep_merge(new_settings)

      differences = Hashdiff.diff(organization_settings, new_organization_settings)

      if differences.present? && differences.map(&:first).all? { |x| x == "+" }
        # rubocop:disable Rails/SkipsModelValidations
        organization.update_attribute(:file_upload_settings, new_organization_settings)
        # rubocop:enable Rails/SkipsModelValidations

        puts "Organization with host #{organization.host} updated. Differences: #{differences.inspect}"
      else
        puts "Organization with host #{organization.host} not updated. Differences: #{differences.inspect}"
      end
    end
  end
end
