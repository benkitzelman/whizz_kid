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

    def notify(message)
      @channel.push message
    end
  end
end