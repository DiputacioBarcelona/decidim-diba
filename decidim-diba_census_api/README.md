# Decidim::DibaCensusApi

A decidim package to provice user authorizations agains the Diputació of Barcelona census API


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-diba_census_api'
```

And then execute:

```bash
bundle
bin/rails decidim_diba_census_api:install:migrations
bin/rails db:migrate
```

## Configuration

Once installed, the following env variables can be configured:

- **DIBA_CENSUS_API_URL**: URL to the DIBA census web service
- **DIBA_CENSUS_API_PUBLIC_KEY**: Public Key used in the DIBA web service authentication

## License

AGPLv3 (same as Decidim)
