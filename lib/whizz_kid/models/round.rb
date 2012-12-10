module WhizzKid
  class Round < BaseObservable
    STATE_READY = :ready
    STATE_RUNNING = :running

    def id
      123
    end

    def initialize(observers, contest)
      @contest = contest
      super observers
    end

    def questions
      [
        'what is the capital of turkey?',
        'what is the capital of australia?',
        'what is the capital of zambia?'
      ]
    end

    def state
      @session.nil? ? STATE_READY : STATE_RUNNING
    end

    def start_questions
      @session = nil if @session && @session.status == false
      @session ||= Thread.new {
        puts "STARTING QUESTIONS"
        questions.each do |question|
          notify "round:question:#{question}"
          puts "SENT #{question} to #{observers.inspect}"
          sleep 5
        end
      }
    end
  end
end