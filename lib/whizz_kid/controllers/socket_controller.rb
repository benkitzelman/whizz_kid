module WhizzKid
  module Controllers
    class SocketController
      attr_reader :message, :player, :game

      def self.routes
        @routes ||= []
      end

      def self.command(route, &block)
        route = route.is_a?(String) ? route.downcase : route
        routes << {route: route, action: block, is_regex: route.is_a?(Regexp) }
      end

      def initialize(game, player)
        @game   = game
        @player = player
      end

      def route_for(command)
        params = []
        r = self.class.routes.find do |route|
          if route[:is_regex] && !!(marked_params = route[:route].match(command))
            params = marked_params[1..-1]
            true
          elsif route[:route] == command.downcase
            true
          end
        end
        [r, params]
      end

      def dispatch(msg)
        begin
          @message  = JSON.parse msg

          route, params = route_for(message['command'])
          return if route.nil?

          response  = self.instance_exec(*params, &route[:action])
          player.send_message(command: @message['command'], data: response)

        rescue Exception => e
          p e.message
          p e.backtrace
        end
      end
    end
  end
end