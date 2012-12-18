module WhizzKid
  module Web
    class RootController < WhizzKid::Web::BaseController
      mount_assets

      helpers do
        def injected_settings
          {
            web_socket_host: WhizzKid.settings.web_socket_host,
            web_socket_port: WhizzKid.settings.web_socket_port,
          }.to_json
        end
      end

      get '/' do
        erb :index
      end
    end
  end
end