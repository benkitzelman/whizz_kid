module WhizzKid
  module Presenters
    class PlayerScore
      def initialize player_score
        @player_score = player_score
      end

      def as_hash
        return if @player_score.nil?
        {
          player:   Presenters::Player.new(@player_score[:player]).as_hash,
          question: Presenters::Question.new(@player_score[:question]).as_hash,
          score:    @player_score[:score],
        }
      end
    end
  end
end