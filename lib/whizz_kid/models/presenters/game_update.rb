module WhizzKid
  module Presenters
    class GameUpdate
      def initialize(game)
        @game = game
      end

      def as_hash(command = "game:update")
        {
          command: command,
          data: {
            state:  @game.state,
            question_timout: Round::QUESTION_TIMEOUT,
          }
        }
      end

    end
  end
end