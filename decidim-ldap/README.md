# Decidim::Ldap

A decidim package to provide user authentication via LDAP. Once is active for an organization,
it is imposible to signup.

The plugin adds a new tab in the Decidim System admin panel that allows to create LDAP configurations
for every organization. Different config parameters can be configured for every organization.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-ldap'
```

And then execute:

```bash
bundle
bin/rails decidim_ldap:install:migrations
bin/rails db:migrate
```

### Run tests

Create a dummy app in your application (if not present):

```bash
bin/rails decidim:generate_external_test_app
cd spec/decidim_dummy_app/
bundle exec rails decidim_ldap:install:migrations
RAILS_ENV=test bundle exec rails db:migrate
cd ../../decidim-ldap
```

And run tests:

```bash
bundle exec rspec spec
```

## Configuration

Once installed, you need to configure the LDAP user credentials that will be used
to perform the ldap binding.

```ruby

Decidim::Ldap.configure do |config|
  config.ldap_username = Rails.application.secrets.ldap[:username]
  config.ldap_password = Rails.application.secrets.ldap[:password]
end
```

## License

AGPLv3 (same as Decidim)
