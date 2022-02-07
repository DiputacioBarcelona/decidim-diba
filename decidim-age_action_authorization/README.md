# Decidim::AgeActionAuthorization

A Decidim based action authorization to check user's age inside actions. The Decidim
[Default Action Authorizer](https://github.com/decidim/decidim/blob/5e5377b4dbb7bfb73f916d7d0a7c41014ac1960f/decidim-verifications/lib/decidim/verifications/default_action_authorizer.rb) only allows comparing items that are equal to an expected value.

This authorization checks a metadata field named _birthday_ in the  AuthorizationHandler used and compares the value against a minimum age defined in the provided JSON for the action authorizer. The JSON field is named _edad_.

E.g: `{"edad": 20 }`.

By default the minimum age is 18 years old if no JSON is provided.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-age_action_authorization'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install decidim-age_action_authorization

## Usage

In the workflow configuration add the AgeActionAuthorization as the workflow's action authorizer:

```ruby
Decidim::Verifications.register_workflow(:authorization_handler) do |workflow|
  workflow.form = 'AuthorizationHandler'
  workflow.action_authorizer = 'Decidim::AgeActionAuthorization::Authorizer'
end
```

### Run tests

Create a dummy app in your application (not in the module):

```bash
cd ..
bin/rails decidim:generate_external_test_app
cd spec/decidim_dummy_app/
cd ../../decidim-age_action_authorization
```

And run tests from the module:

```bash
bundle exec rspec spec
```
