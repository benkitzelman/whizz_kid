module WhizzKid
  module Presenters
    class RoundUpdate
      def initialize round
        @round = round
      end

      def as_hash command = "round:update"
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
          scores:           @round.scores,
          current_question: @round.current_question,
        }
      end

      def completed
        in_play.merge(
          results: {
            winning_scores:       @round.winning_scores,
            highest_player_score: @round.highest_player_score,
          }
        )
      end
    end
  end
end