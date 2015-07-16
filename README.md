# Hubstats [![Build Status](https://travis-ci.org/sportngin/hubstats.svg?branch=master)](https://travis-ci.org/sportngin/hubstats)

Hubstats is a rails plugin which allows you to search and monitor pull requests made across a collection of repositories. It also gives extra statistics about users and pull requests not found on GitHub.

## Setup
The following setup is designed to only be used when integrating this plugin into a rails application or for when adding new migrations.

 Run `rails generate hubstats:install`.
 
 Configure `octokit.yml` with your Github information.

 Run `rake hubstats:install:migrations`.

 Run `rake hubstats:setup` to run the necessary migrations and start pulling data from Github.

 Add 'mount Hubstats::Engine => "/hubstats"' to your apps routes file.

## Configuration
### Authentication
Hubstats needs Github credentials to access your repositories, these can be setup in one of two ways:

#### Configuring the `octokit.yml`
Add your GitHub API token (called `access_token`) or ClientID and Secret to `octokit.yml`.

#### Environment Variables
Hubstats can also use OAUTH access tokens stored in ENV["GITHUB_API_TOKEN"] or for Application Authentication in ENV["CLIENT_ID"] and ENV["CLIENT_SECRET"], if for some reason you don't want to store them in `octokit.yml`.

### Webhooks
Hubstats uses GitHub webhooks to keep itself updated. It requires you to set a secret as well as an endpoint to push to.

To generate a secret run:
 ```
 ruby -rsecurerandom -e 'puts SecureRandom.hex(20)'
 ``` 
Set the endpoint to be:

 www.yourdomain.com/hubstats/handler
 
### Repositories 
Hubstats needs to know what repositories for it to watch. You can set it to watch either an entire organization or a list of specific repositories in `octokit.yml`. The list of repositories should look like either:

```
repo_list:
 - sportngin/hubstats
 - sportngin/active_zuora
 - sportngin/make-resourceful
```

or 

```
org_name: sportngin
```

### Teams
Hubstats tracks teams that are whitelisted in the `octokit.yml`. It is recommended that you make teams dedicated for hubstats team based metrics so they are isolated from permissions focused teams.The list of teams should look something like:

```
team_list:
 - Team One
 - Team Two
 - Team Three
```

Also, the GitHub API token in `octokit.yml` must be a member of all of the teams listed. On the `app/views/hubstats/partials/_team.html.erb`, the dummy user is automatically accounted for by subtracting one from the user count. Otherwise, there is a section in the `octokit.yml` for any ignored users. The dummy user (and any others), can be placed here, and they won't show up on the list of users in a team.

## Testing
All of the automated tests are written in RSpec. To run these tests, run the following commands, assuming that there are two already existent local databases titled `hubstats_development` and `hubstats_test`:
```
cd test/dummy/
rake db:test:prepare
bundle exec rspec
```
To test what Hubstats would actually look like on a web browser, we need to install the plugin into a Rails application to run. This is because Hubstats is a plugin, not an application. The `test` directory is also a dummy rails application for manually testing the UI by serving Hubstats locally. When developing and using the `test/dummy` locally, then the test will automatically sync with any updated code, so it doesn't need to be re-served when changes are made with the normal Rails application. When in the development process, one just needs to run:
```
cd test/dummy/
bundle exec rails s
```
to serve the plugin. http://guides.rubyonrails.org/plugins.html will give more information on the implementation of a Rails plugin. 

## TL:DR
  Run `rails generate hubstats:install`.
  
  Configure `octokit.yml` with your Github information.
  
  Run `rake hubstats:install:migrations`.
  
  Run `rake hubstats:setup`.
  
  Add 'mount Hubstats::Engine => "/hubstats"' to your routes file.

<hr>

This project rocks and uses MIT-LICENSE.
