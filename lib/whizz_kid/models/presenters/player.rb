module WhizzKid
  module Presenters
    class Player
      def initialize player
        @player = player
      end

      def as_hash
        return if @player.nil?
        {
          name: @player.name,
        }
      end
    end
  end
end