module WhizzKid
  class BaseObservable
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