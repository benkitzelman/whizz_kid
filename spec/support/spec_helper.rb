ENV['RACK_ENV'] = 'test'
here = File.dirname(__FILE__)

require 'rubygems'
require 'bundler'
Bundler.setup

require File.join here, '../', '../', 'bootstrap'