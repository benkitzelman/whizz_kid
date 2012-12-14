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
require 'lib/bootstrap'
require 'lib/whizz_kid'
require 'lib/whizz_kid/controllers/socket_controller'
[
  'lib', 'app', 'app/controllers', 'app/models', 'app/config/initializers', 'lib/whizz_kid/models', 'lib/whizz_kid/models/presenters', 'lib/whizz_kid/controllers'
].each do |folder|
  Dir["#{folder}/*.rb"].each {|file| require file }
end

require "app/config/app_config"
require "app/config/#{Bootstrap.environment}"
require 'app/application'
