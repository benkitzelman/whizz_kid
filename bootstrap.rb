$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'
require 'json'

if ENV['RACK_ENV'] == 'test'
  require 'rack/test'
end

require 'sinatra'
require 'sinatra/url_for'
require 'coffee-script'
require 'lib/whizz_kid'
require 'lib/whizz_kid/base_observable'
require 'lib/whizz_kid/controllers/socket_controller'
require 'lib/whizz_kid/web/controllers/base_controller'
[
  'lib', 'lib/whizz_kid', 'lib/whizz_kid/web/controllers', 'lib/whizz_kid/presenters', 'lib/whizz_kid/controllers'
].each do |folder|
  Dir["#{folder}/*.rb"].each {|file| require file }
end

require "config/app_config"
require "config/initializers/#{WhizzKid.environment}"
require 'lib/whizz_kid/web/application'
