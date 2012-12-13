module WhizzKid
  def self.start
    EventMachine.run {
      @game = WhizzKid::Game.start(Channel.new)

      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|

        ws.onopen {
          player = @game.player_connected ws

          ws.onclose {
            player.unsubscribe_all
          }

          ws.onmessage { |msg|
            message = JSON.parse msg
            case message['command']

            when /^game:join$/
              players_team  = message['data'].delete('selected_team')
              round         = @game.join_or_create_round message['data'], player, players_team
              player.send_message Presenters::RoundUpdate.new(round).as_hash("game:joined")

            when /round:([^:]+):question:([^:]+):answer:([^:]+)/
              round = @game.rounds.find {|r| r.id == $1.to_i}
              round.answer(player, $2, $3)
              player.send_message Presenters::RoundUpdate.new(round).as_hash("round:answer-received")
            end
          }

          player.send_message Presenters::GameUpdate.new(@game).as_hash('game:ready')
        }
      end
    }
  end
end
