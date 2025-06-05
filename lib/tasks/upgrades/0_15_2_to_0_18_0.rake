# frozen_string_literal: true

namespace :upgrade do
  desc "Starts a new ldap server with Ladle"
  # rubocop:disable Naming/VariableNumber
  task from_0_15_2_to_0_18_0: :environment do
    # rubocop:enable Naming/VariableNumber

    puts "\n\n **** START MIGRATION FROM 0.15.2 to 0.18.0 🚀 ****"

    puts " \n == 0.16.0 required tasks 🤖 =="

    puts " -- migrate_data_to_decidim_forms"
    Rake::Task["decidim_surveys:migrate_data_to_decidim_forms"].invoke

    puts " -- Populate help content to existing organizations"
    Decidim::Organization.find_each do |organization|
      puts "   - populate help to: #{organization.id}"
      Decidim::System::PopulateHelp.call(organization)
    end

    # require a cronjob that exeacute recurrently:
    puts "   🚨 Remember add a cron job with: bundle exec rake decidim:open_data:export"

    puts " \n == 0.16.1 required tasks 💻 =="
    Decidim::UserBaseEntity.find_each do |entity|
      follower_count = Decidim::Follow.where(followable: entity).count
      following_count = Decidim::Follow.where(decidim_user_id: entity.id).count

      # We use `update_columns` to skip Searchable callbacks
      # rubocop: disable Rails/SkipsModelValidations
      entity.update_columns(
        followers_count: follower_count,
        following_count:
      )
      # rubocop: enable Rails/SkipsModelValidations
    end

    puts " \n == 0.18.0 required tasks 💪 =="
    days = (Date.parse(2.months.ago.to_s)..Date.yesterday).uniq
    Decidim::Organization.find_each do |org|
      old_metrics = Decidim::Metric.where(organization: org).where(metric_type: "participants")
      days.each do |day|
        new_metrics = Decidim::Metrics::ParticipantsMetricManage.new(day.to_s, org)
        ActiveRecord::Base.transaction do
          old_metrics.where(day:).delete_all
          new_metrics.save
        end
      end
    end

    puts " \n == Fixe permissions in some Decidim::Component entities 👾 =="
    puts "    Note: when the permission has the value { 'authorization_handler_name' => nil } causes problems"
    Decidim::Component.all.select { |a| a&.permissions&.has_value?("authorization_handler_name" => nil) }.each do |component|
      component.permissions.each do |key, value|
        component.permissions[key].except!("authorization_handler_name") if value == { "authorization_handler_name" => nil }
        component.save
        puts " - Component #{component.id} removed { 'authorization_handler_name' => nil } to the key #{key}"
      end
    end

    puts "\n\n **** Finish!!! 🎉 ****"
  end
end
