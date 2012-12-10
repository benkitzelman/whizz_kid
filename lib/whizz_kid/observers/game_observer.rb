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

      def on_service_message message
        puts "GAME sent to client: #{message}"
        send_message message
      end
    end
  end
end
