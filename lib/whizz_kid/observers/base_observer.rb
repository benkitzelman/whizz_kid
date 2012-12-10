module WhizzKid
  module Observers
    class BaseObserver
      attr_reader :socket

      def initialize(web_socket)
        @socket = web_socket
      end

      # from whizz_kid
      def update(event)
        on_service_message event if respond_to?(:on_service_message)
      end

      # from socket
      def on_open
        puts 'new client connection'
        on_client_joined if respond_to?(:on_client_joined)
      end

      def on_close
        puts 'client connection closed'
        on_client_left if respond_to?(:on_client_left)
      end

      def on_message(msg)
        @last_message = msg
        on_client_message(last_message) if respond_to?(:on_client_message)
      end

      def send_message(msg)
        @socket.send msg
      end

      def last_message
        @last_message.split(':').map {|chunk| chunk.downcase.to_sym}
      end

      def self.inherited(subclass)
        WhizzKid.register_observer(subclass)
      end
    end
  end
end
