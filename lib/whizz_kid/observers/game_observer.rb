module WhizzKid
  module Observers
    class GameObserver < BaseObserver
      def initialize *args
        Game.instance.attach self
        super *args
      end

      def on_client_message message
        return unless message[0] == :game
        puts "Client sent to GAME: #{message.inspect}"
      end

      def on_service_message event
        puts "GAME sent to client: #{event}"
        @socket.send event
      end
    end
  end
end
