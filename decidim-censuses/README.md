# Census

> Add census authorization to Decidim platform

Allows to upload a census CSV file to perform authorizations agains real user age.

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