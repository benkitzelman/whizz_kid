module WhizzKid
  module Controllers
    class Game < SocketController

      command "game:join" do
        players_team  = message['data'].delete('selected_team')
        if round = game.join_or_create_round(message['data'], player, players_team)
          Presenters::RoundUpdate.new(round).as_hash("game:joined")
        else
          Presenters::Error.as_hash("game:no-rounds")
        end
      end

      command %r{round:([^:]+):question:([^:]+):answer:([^:]+)} do |round_id, question_id, answer|
        round   = game.rounds.find {|r| r.id == round_id.to_i}
        answer  = round.answer(player, question_id, answer)
        command = case answer
        when true
          "round:answer-correct"
        when false 
          "round:answer-incorrect"
        else
          "round:answer-closed"
        end

        Presenters::RoundUpdate.new(round).as_hash(command)
      end
    end
  end
end