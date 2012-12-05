module WhizzKid
  module Observers
    class BaseObserver
      def initialize(web_socket)
        @socket = web_socket
      end

      def on_open
        puts "OBSERVER OPEN"
      end

      def on_close
        puts "OBSERVER CLOSED"
      end

      def on_message(msg)
        puts "OBSERVER MSG: #{msg}"
      end

      def self.inherited(subclass)
        WhizzKid::Notifier.register_observer(subclass)
      end
    end

    class GameObserver < BaseObserver
      def on_message(msg)
        puts "GAME OBSERVER MSG: #{msg}"
      end
    end
  end
end