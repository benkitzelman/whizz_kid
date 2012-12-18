require 'sinatra/base'
require 'sinatra/assetpack'

module WhizzKid
  module Web
    class BaseController < Sinatra::Base
      set :sessions, true
      set :root, File.dirname(__FILE__)
      set :public_folder, Proc.new { File.join(WhizzKid.root, "public" ) }
      set :views, File.join(WhizzKid.root, "lib", "whizz_kid", "web", "views" )

      def self.mount_assets
        set :sass,{ :load_paths => [ WhizzKid.root + "assets/stylesheets" ] }

        register Sinatra::AssetPack

        assets {
          serve '/javascripts', from: "../../../../assets/javascripts"
          serve '/stylesheets', from: '../../../../assets/stylesheets'

          js :application, '/javascripts/application.js', [
            '/javascripts/vendor/*.js',
            '/javascripts/app/*.js'
          ]

          css :application, '/stylesheets/application.css', [
            '/stylesheets/skeleton/*.css',
            '/stylesheets/*.css'
          ]

          js_compression  :uglify
          css_compression :sass
        }
      end
    end
  end
end