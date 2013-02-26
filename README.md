Procure.io [![](https://travis-ci.org/adamjacobbecker/procure-io.png)](https://travis-ci.org/adamjacobbecker/procure-io) [![](https://codeclimate.com/github/adamjacobbecker/procure-io.png)](https://codeclimate.com/github/adamjacobbecker/procure-io)
--------

Procurement software for the 21st century.

#### Setting up your development environment
1. `git clone` the repo
2. `bundle install`
3. copy `config/database.yml.example` to `config/database.yml` and configure it as needed
4. `rake db:setup`
5. `rails server` or run with your choice of server (we like [pow](http://pow.cx/))

#### Contributing

Procure.io is very early-stage alpha software, but if you're interested in getting your hands dirty, contributions are more than welcome. Your workflow should look something like this:

1. Fork the repo
2. Write some sweet code
3. Write some tests (unit & acceptance, currently) that cover the functionality you added
4. Create a pull request

#### License
Procure.io is released under the [MIT License](http://opensource.org/licenses/MIT).
