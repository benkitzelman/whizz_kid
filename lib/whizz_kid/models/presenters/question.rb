module WhizzKid
  module Presenters
    class Question
      def initialize(question)
        @question = question
      end

      def as_hash
        return unless @question

        {
          id:       @question.id,
          number:   @question.number,
          question: @question.question,
          closed:   @question.closed,
        }.tap do |q|
          if @question.options
            q[:options] = @question.options.map {|o| o['text']}
          end
        end
      end
    end
  end
end