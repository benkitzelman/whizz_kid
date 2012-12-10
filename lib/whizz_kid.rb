module WhizzKid
  def self.start
    EventMachine.run {
      @game_channel = EventMachine::Channel.new
      @game         = WhizzKid::Game.start(@game_channel)

      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|

        ws.onopen {
          sid = @game_channel.subscribe {|msg| ws.send msg}
          ws.send 'game:started'
        }

        ws.onclose {
          @game_channel.unsubscribe(sid)
        }

        ws.onmessage { |msg|
          case msg
          when /game:join:(.+)/
            @game.join_or_create_round $1
          end
        }
      end
    }
  end
end
