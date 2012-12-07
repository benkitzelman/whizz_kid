module Notifier
  def self.start
    EventMachine.run {
      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|

        observer_instances = observers.map {|ob| ob.new(ws)}

        ws.onopen {
          observer_instances.each(&:on_open)
          @game ||= WhizzKid::Game.start ws
        }

        ws.onclose {
          observer_instances.each(&:on_close)
        }

        ws.onmessage { |msg|
          observer_instances.each {|observer| observer.on_message msg}
        }
      end
    }
  end

  def self.observers
    @observers ||= []
  end

  def self.register_observer(klass)
    observers << klass
  end
end
