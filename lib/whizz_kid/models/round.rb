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
        {id: 1, question: 'what is the capital of england?', answer: 'london'},
        {id: 2, question: 'what is the capital of zambia?', answer: 'lusaka'},
        {id: 3, question: 'what is the capital of australia?', answer: 'canberra'},
      ]
    end

    def state
      @session.nil? ? STATE_READY : STATE_RUNNING
    end

    def start_questions
      @session = nil if @session && @session.status == false
      @session ||= Thread.new {
        questions.each do |question|
          notify "round:question:#{question[:id]}:#{question[:question]}"
          sleep 5
        end
      }
    end
  end
end