module WhizzKid
  class BaseObservable
    attr_reader :state

    def initialize(observers = nil)
      @observers = observers
      @state = 'pre-init'
    end

    def notify(message)
      socket.send message
    end

    def observers
      @observers ||= []
    end

    def attach(observer)
      observers << observer
    end

    def detach(observer)
      observers -= [observer]
    end

    def notify(message)
      observers.each{|o| o.update message}
    end
  end
end