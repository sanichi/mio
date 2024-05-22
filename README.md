# README

This rails app is Mark Orr‘s personal [website](https://sandradickie.co.uk/).

To run/test locally:

* Install the version of ruby in `.ruby-version`.
* Run `bin/bundle install`.
* Overwrite `config/credentials.yml.enc` with a new `config/master.key`.
* For functionality related to [WaniKani](https://www.wanikani.com), make sure that the credentials contain an API key:
```
wani_kani:
  api2: ...
```
* Make sure you have PostgreSQL running locally.
* Create the unversioned file `config/database.yml` something like this:
```
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  username: blah
  password: blah
development:
  <<: *default
  database: mio_development
test:
  <<: *default
  database: mio_test
```
* Run `bin/rails db:create`.
* Sync the development database with the production database if you can.
* If you can't sync then at least create one admin user with `bin/rails c`:
```
User.create!(email: "...", password: "...", first_name: "...", last_name: "...", role: "admin")
```
* Run the app locally on port 3000 with `bin/rails s`.
* Test by running `bin/rake`.
