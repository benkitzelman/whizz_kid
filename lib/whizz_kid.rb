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
              if round = @game.join_or_create_round(message['data'], player, players_team)
                player.send_message Presenters::RoundUpdate.new(round).as_hash("game:joined")
              else
                player.send_message Presenters::Error.as_hash("game:no-rounds")
              end

            when /round:([^:]+):question:([^:]+):answer:([^:]+)/
              round   = @game.rounds.find {|r| r.id == $1.to_i}
              answer  = round.answer(player, $2, $3)
              command = case answer
              when true
                "round:answer-correct"
              when false 
                "round:answer-incorrect"
              else
                "round:answer-closed"
              end
              player.send_message Presenters::RoundUpdate.new(round).as_hash(command)

            end
          }

          player.send_message Presenters::GameUpdate.new(@game).as_hash('game:ready')
        }
      end
    }
  end
end
