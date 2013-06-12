Procure.io Community Version [![](https://codeclimate.com/github/dobtco/procure-io.png)](https://codeclimate.com/github/dobtco/procure-io)
--------

Procurement software for the 21st century.

<em><strong>What's this "Community Version"?</strong> Nearly identical to our SaaS product, just with some of the multi-tenancy code taken out.</em> Try the **[demo](http://community-demo.procure.io/)**.

> Login to the demo as an officer with `user1@example.com` and `password`.

[![screenshot](http://www.dobt.co/img/review_bids.png)](http://www.dobt.co/img/review_bids.png)

#### Setting up your development environment
- `git clone` the repo
- `bundle install`
- copy `config/database.yml.example` to `config/database.yml` and configure it as needed
- `rake db:setup`
- `rake db:seed:example`
- `rails server` or run with your choice of server (we like [pow](http://pow.cx/))
- `rake jobs:work` to run delayed_job worker

> You'll all set to develop Procure.io. Login with `user1@example.com` and `password`.

#### Deploying to Heroku

Since this is a Rails 4 app, it requires some extra steps the first time you deploy it.

- `heroku create YOUR_APP_NAME`
- `heroku labs:enable user-env-compile`
- `heroku addons:add heroku-postgresql`
- Setup (or disable) the mailer in production.rb
- Add the environment variables specified in `.powenv.example`
- Add an additional environment variable with the database URL
  - `heroku config` to see the existing database URL
  - `heroku config:set DATABASE_URL="YOURDATABASEURLHERE"`
- `git push heroku master`
- `heroku run rake db:migrate`
- Launch a console `heroku run rails console` and:
- Create an organization: `Organization.create(name: "Oakland", email: "example@oakland.com", username: "oakland")`
- Create a user: `User.create(email: "adam@dobt.co", name: "Adam Becker", password: "password")`
- Assign that user to the organization's owners team:  `Organization.first.owners_team.users << User.first`

##### A couple notes:
- Procure.io uses delayed_job to run tasks asynchronously. Running a worker dyno costs $34.50/month, so if you want to avoid this charge, you'll have to disable the worker in the `Procfile`, and configure delayed_job with `Delayed::Worker.delay_jobs = false`.

- Procure.io is configured to use AWS for storing file uploads. You'll need to set environment variables for this too (specified in `/.powenv.example`), or change your application configuration to use another storage provider. Note that you can't use `:file` storage on Heroku, as the filesystem is not permanently writable.

#### Contributing

Procure.io is very early-stage alpha software, but if you're interested in getting your hands dirty, contributions are more than welcome. Your workflow should look something like this:

1. Fork the repo
2. Write some sweet code in a feature-branch
3. Write some tests (unit & acceptance, currently) that cover the functionality you added
4. Create a pull request

#### Copyright
Released under the [GNU GPLv3 license](https://www.github.com/dobtco/procure-io/blob/master/LICENSE.md). Neither the name of the Department of Better Technology nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
