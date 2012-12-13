module WhizzKid
  module Presenters
    class Error
      def self.as_hash(message)
        Error.new(message).as_hash
      end

      def initialize(message)
        @message = message
      end

      def as_hash
        {
          error: @message
        }
      end
    end
  end
end