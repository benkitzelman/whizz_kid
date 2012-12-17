module WhizzKid
  module Controllers
    class Game < SocketController

      command "game:join" do
        players_team  = message['data'].delete('selected_team')
        if round = game.join_or_create_round(message['data'], player, players_team)
          Presenters::RoundUpdate.new(round).as_hash[:data]
        else
          false
        end
      end

      command "game:can-service" do
        subject = message['data']
        game.can_service subject
      end

      command %r{round:([^:]+):question:([^:]+):answer:([^:]+)} do |round_id, question_id, answer|
        round   = game.rounds.find {|r| r.id == round_id.to_i}
        round.answer player, question_id, answer
      end

    end
  end
end