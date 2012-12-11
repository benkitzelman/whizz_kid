module WhizzKid
  def self.start
    EventMachine.run {
      @game = WhizzKid::Game.start(EventMachine::Channel.new)

      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|

        ws.onopen {
          sid = @game.subscribe ws

          ws.onclose {
            @game.unsubscribe(sid)
          }

          ws.onmessage { |msg|
            case msg

            when /game:join:(.+)/
              round = @game.join_or_create_round $1, ws
              ws.send "game:joined:#{round.contest}"

            when /round:([^:]+):question:([^:]+):answer:([^:]+)/
              round = @game.round_for $1
              ws.send "round:#{$1}:question:#{$2}:correct:#{round.answer($2, $3)}"
            end
          }

          ws.send 'game:started'
        }
      end
    }
  end
end
