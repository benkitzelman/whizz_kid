module WhizzKid
  class Player
    attr_reader :socket, :channel_subscriptions

    def initialize(socket)
      @socket = socket
      @channel_subscriptions = []
    end

    def send_message message
      socket.send message.to_json
    end

    def unsubscribe_all
      channel_subscriptions.each do |sub|
        sub[:on_unsubscribe].call if sub[:on_unsubscribe]
        sub[:channel].unsubscribe sub[:sid]
      end
    end
  end
end