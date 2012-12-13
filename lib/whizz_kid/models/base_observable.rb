module WhizzKid
  class BaseObservable
    attr_reader :state, :channel

    def initialize(channel = nil)
      @channel  = channel
      @state    = 'pre-init'
    end

    def subscribe(socket)
      @channel.subscribe {|msg| socket.send msg}
    end

    def unsubscribe(sid)
      @channel.unsubscribe sid
    end

    def notify(message)
      @channel.push message.to_json
    end
  end
end