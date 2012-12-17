module WhizzKid
  module Presenters
    class RoundUpdate
      def initialize round
        @round = round
      end

      def as_hash command = "round:update"
        return if @round.nil?
        {
          command:  command,
          data:     @round.state == :completed ? completed : in_play,
        }
      end

      def in_play
        {
          id:               @round.id,
          state:            @round.state,
          subject:          @round.subject,
          scores:           @round.scores.map {|team_score| Presenters::TeamScore.new(team_score).as_hash },
          current_question: Presenters::Question.new(@round.current_question).as_hash,
          total_questions:  @round.questions.length,
        }
      end

      def completed
        in_play.merge(
          results: {
            winning_scores:         @round.winning_scores.map {|team_score| Presenters::TeamScore.new(team_score).as_hash },
            highest_player_score:   player_score(@round.highest_player_score),
          }
        )
      end

      def player_score player_score
        {
          player: Presenters::Player.new(player_score[:player]).as_hash,
          total:  player_score[:total],
        }
      end
    end
  end
end