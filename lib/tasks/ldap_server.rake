# frozen_string_literal: true

namespace :ldap do
  desc "Starts a new ldap server with Ladle"
  task server: :environment do
    # for config options see: https://github.com/NUBIC/ladle/blob/master/lib/ladle/server.rb
    server = Ladle::Server.new(
      port: 3897,
      ldif: Rails.root.join("decidim-ldap/lib/ladle/default.ldif"),
      domain: "dc=example,dc=com"
    )

    server.start
    puts "Press q to exit"
    option = $stdin.gets until (option || "").chomp == "q"
    server.stop
  end
end
