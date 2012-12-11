module WhizzKid
  class BaseObservable
    attr_reader :state

    def initialize(channel = nil)
      @channel = channel
      @state = 'pre-init'
    end

    def channel
      @channel
    end

    def subscribe(socket)
      @channel.subscribe {|msg| socket.send msg}
    end

    def unsubscribe(sid)
      @channel.unsubscribe sid
    end

    def notify(message)
      @channel.push message
    end
  end
end