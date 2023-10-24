# README

## Update Decidim

To update the Decidim installation on this project, first we update Gemfile
dependencies, then we call the Decidim upgrade script and then we apply
migrations (if any)

* `bundle update decidim decidim-dev`
* `bin/rails decidim:upgrade`
* `bin/rails db:migrate`

There are some customizations that have been done to the platform. During an upgrade
all the files that have been overridden need to be checked to ensure compatibility.
[docs/overrides.md](docs/overrides.md) lists all these modifications.

## Upgrade Ruby

To upgrade the Ruby version, the following files are involved:

- .ruby-version
- Dockerfile.production: The first line defines the image to be build over `FROM phusion/passenger-ruby27:1.0.12`. Meaning that it is Passenger with Ruby 2.7.
- `docker/nginx.conf` The Nginx config should be updated to load the correct Ruby version for `passenger_ruby`.

That's all.

## Development

**Requeriments (MacOS)**

GraphicsMagick is required to be installed. For example (with `brew`): `brew
install graphicsmagick`

**Development environment installation**

* Install development environment (Ruby 2.4+, PostgreSQL 9.4+). Check the
  following guide for instructions on different OS: https://gorails.com/setup/
* Clone the repository: `git clone git@github.com:diputacioBCN/decidim-diba.git`
* `cd decidim-diba`
* Install dependencies: `bundle install`
* Setup database: `bin/rails db:setup`
* Launch development server: `bin/rails server`

More information can be found in the Decidim github repository:
https://github.com/decidim/decidim

**Utils**

### tasks in `lib/tasks/diba.rake`

```
# Finds information about the Organization, or Organizations, searching by the :host_term argument
bin/rake diba:org_by_host_like[vallirana]
```

Optional :full second parameter. Set it to true to see all the Organization's information.

### tasks in `lib/tasks/census_api`

```
# Checks the given credentials against the census_api (document_type dni/nie/passport, birthdate yyyy/mm/dd)
rake census_api:check[org_id,document_type,id_document,birthdate]
# Is there a Decidim::Authorization for the given document?
rake census_api:find_authorization_by_doc[document,birthdate]
# Returns the DibaCensusApiAuthorizationHandler encoded version of the document argument
rake census_api:to_unique_id[document]
```

**Run tests**

Use: `bin/rspec` (with spring) or `bundle exec rspec` (without spring)

**Testing emails in development**

Decidim is using the
[letter_opener_web](https://github.com/fgrehm/letter_opener_web) gem. To see all
emails sent in the development environment you can do it by visiting the
https://localhost:3000/letter_opener URL.

**Testing LDAP integration in development**

To launch a development ldap server, you can use:

`rake ldap:server`

You can find a sample LDAP configuration in: `decidim-ldap/spec/factories.rb` and a list
of users inside `decidim-ldap/lib/ladle/default.ldif`

Start the app with the development ldap environment variables:
```
export LDAP_USERNAME=uid=admin,ou=people,dc=example,dc=com
export LDAP_PASSWORD=password123456
bin/rails s
```

When signing in, the following fields from the `default.ldif` should ve used:

- uid: for the email, e.g. "Alice".
- userPassword: for the password, e.g. "password123456".


**Specific issues**

* The translations are available only in catalan, spanish and english.
* You can configure the minimum age of a feature using the following json:
  `{"edad": 20 }`. By default the minimum age is 18 years old.

## Docker Hub
To publish to docker hub:

```
DIBA_TAG=v13.1.4-decidim_0.26.8
DIBA_DOCKER_TAG=diputaciobcn/decidim-diba:$DIBA_TAG
docker build --network=host -f Dockerfile.production -t $DIBA_DOCKER_TAG .
docker tag $DIBA_DOCKER_TAG diputaciobcn/decidim-diba:latest
docker push $DIBA_DOCKER_TAG
docker push diputaciobcn/decidim-diba:latest
git tag -a $DIBA_TAG -m $DIBA_TAG
git push origin $DIBA_TAG
```
