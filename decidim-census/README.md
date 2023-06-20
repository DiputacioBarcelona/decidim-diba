# Census

> Add census authorization to Decidim platform

Allows to upload a census CSV file to perform authorizations against
real users parameterised by their age.

## Usage

This module provides a model `Decidim::Census::Census` to store census information (identity document and birth date).

It has an admin controller to upload CSV files with the information. When importing files all records are inserted and the duplicates are removed in a background job for performance reasons.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-census'
```

And then execute:

```bash
bundle
bin/rails decidim_census:install:migrations
bin/rails db:migrate
```

## Run tests

```bash
cd decidim-census
bundle exec rake decidim:generate_external_test_app
cd spec/decidim_dummy_app/
bundle exec rails decidim_census:install:migrations
RAILS_ENV=test bundle exec rails db:migrate
cd ../../decidim-census
```

And run tests:

```bash
bundle exec rspec spec
```

## License

AGPLv3 (same as Decidim)
