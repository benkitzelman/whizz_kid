module WhizzKid
  module Observers
    class GameObserver < BaseObserver

      def on_service_message message
        send_message message
      end

      def on_client_message message
        return unless message[0] == :game
        puts "Client sent to GAME: #{message.inspect}"

        case message[1]
        when :join
          Game.instance.join_or_create_round message[2]
        end
      end

    end
  end
end
