module WhizzKid
  class Round < BaseObservable
    def questions
      [
        'what is the capital of turkey?',
        'what is the capital of australia?',
        'what is the capital of zambia?'
      ]
    end

    def start_questions
      Thread.new {
        questions.each do |question|
          sleep 10
          notify "round:question:#{question}"
        end
      }
    end
  end
end