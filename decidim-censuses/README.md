# Census

> Add census authorization to Decidim platform

Allows to upload a census CSV file to perform authorizations agains real user age.

## Usage

This module provides a model `Decidim::Censuses::Census` to store census information (identity document and birth date).

It has an admin controller to upload CSV files with the information. When importing files all records are inserted and the duplicates are removed in a background job for performance reasons.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-census'
```

And then execute:

```bash
$ bundle
$ bin/rails railties:install:migrations
$ bin/rails db:migrate
```

## Run tests

Create a dummy app:

```bash
$ bin/rails decidim:generate_test_app
```

And run tests:

```bash
$ cd decidim-censuses
$ rspec
```



## License

AGPLv3 (same as Decidim)