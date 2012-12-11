module WhizzKid
  class Round < BaseObservable
    STATE_READY = :ready
    STATE_RUNNING = :running
    attr_reader :contest, :score

    def id
      123
    end

    def initialize(contest)
      @contest = contest
      reset
      super EventMachine::Channel.new
    end

    def questions
      [
        {id: 1, question: 'what is the capital of england?', answer: 'london'},
        {id: 2, question: 'what is the capital of zambia?', answer: 'lusaka'},
        {id: 3, question: 'what is the capital of australia?', answer: 'canberra'},
      ]
    end

    def state
      @session.nil? ? STATE_READY : STATE_RUNNING
    end

    def start_questions
      round_questions = questions
      @session ||= EM.add_periodic_timer(5) {
        if question = round_questions.shift
          notify "round:question:#{question[:id]}:#{question[:question]}"
        else
          reset
        end
      }
    end

    def reset
      puts "INITIALIZING ROUND #{@contest}"
      EM.cancel_timer @session
      @score    = 0
      @session  = nil
    end

    def answer question_id, answer
      return unless question = questions.find {|q| q[:id] == question_id.to_i}

      if question[:answer].downcase == answer.downcase
        @score += 1
        notify "game:score:#{@score}"
        true
      else
        false
      end
    end
  end
end