# common config
puts "-- loading #{WhizzKid.environment} environment"
require 'settingslogic'
module WhizzKid
  module Config
    class AppConfig < ::Settingslogic
      source  File.join File.dirname(__FILE__), "app_config.yml"
      namespace WhizzKid.environment.to_s
    end
  end
end