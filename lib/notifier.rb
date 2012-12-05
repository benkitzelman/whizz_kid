['lib/whizz_kid/controllers', 'lib/whizz_kid/observers'].each do |folder|
  Dir["#{folder}/*.rb"].each {|file| require file }
end
module WhizzKid
module Notifier
  def self.start
    EventMachine.run {
      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
        observer_instances = observers.map {|ob| ob.new(ws)}

        ws.onopen {
          puts "WebSocket connection open"
          observer_instances.each(&:on_open)
          # publish message to the client
          ws.send "Hello Client"
        }

        ws.onclose {
          observer_instances.each(&:on_closed)
          puts "Connection closed"
        }

        ws.onmessage { |msg|
          puts "Recieved message: #{msg}"
          observer_instances.each(&:on_message)
          # this is crap - need to can it
          WhizzKid::Controllers::Game.new(ws).dispatch msg
        }
      end
    }
  end

  def self.observers
    @observers ||= []
  end

  def self.register_observer(klass)
    puts 'registering'
    observers << klass
  end
end
end