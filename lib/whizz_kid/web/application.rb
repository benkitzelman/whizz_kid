module WhizzKid
  module Web
    class Application < Rack::URLMap
      def initialize
        super({
          '/'     => WhizzKid::Web::RootController,
          '/api'  => WhizzKid::Web::APIController,
        })
      end
    end
  end
end
