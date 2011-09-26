# This code is licensed under the MIT license (see LICENSE file for details)
source 'http://rubygems.org'

# We are nailing one specific version here
gem 'rails', '3.0.9'

# See http://j-k.lighthouseapp.com/projects/45560/tickets/177-ruby-192-undefined-method-reveal-for-actsasferretsearchresultsclass
gem 'acts_as_ferret', '= 0.5.2', :git => "git://github.com/primerano/acts_as_ferret.git"

# Can not go higher unless we somehow get ActiveRecord separately.
gem 'mysql2', '< 0.3'

# For pagination, better than will_paginate
gem 'kaminari'

# Legacy support for Prototype stuff - observe_field etc
gem 'prototype_legacy_helper', '0.0.0', :git => 'git://github.com/rails/prototype_legacy_helper.git'

# SSL requirements can be expressed in route.rb these days, but
# this gem maintains the old style of doing it in the controllers.
gem 'bartt-ssl_requirement', :require => 'ssl_requirement'

# Instead of attachment_fu - it is better.
gem "paperclip"

# Added tools only for development
group :development do
  gem 'annotate'
  gem 'magic_encoding'
end

# Using Rack::Test for simple unit testing of the REST api.
gem 'rack-test'



# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
# gem 'sqlite3'
#
# Use unicorn as the web server
# gem 'unicorn'
#
# Deploy with Capistrano
# gem 'capistrano'
#
# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'
#
# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'
#
# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
