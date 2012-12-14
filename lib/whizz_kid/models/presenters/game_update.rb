module WhizzKid
  module Presenters
    class GameUpdate
      def initialize(game)
        @game = game
      end

      def as_hash(command = "game:update")
        return if @game.nil?
        {
          command: command,
          data: {
            state:  @game.state,
            question_timeout: Round::QUESTION_TIMEOUT,
          }
        }
      end

    end
  end
end