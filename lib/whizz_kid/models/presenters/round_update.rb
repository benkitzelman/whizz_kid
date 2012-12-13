module WhizzKid
  module Presenters
    class RoundUpdate
      def initialize(round)
        @round = round
      end

      def as_hash(command = "round:update")
        {
          command: command,
          data: {
            id:               @round.id,
            subject:          @round.subject,
            scores:           @round.scores.tap{|s| p s},
            current_question: @round.current_question,
          }
        }
      end

    end
  end
end