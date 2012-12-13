module WhizzKid
  class Round < BaseObservable
    STATE_READY     = :ready
    STATE_RUNNING   = :running
    STATE_COMPLETED = :completed

    QUESTION_TIMEOUT = 10

    attr_reader :subject, :scores, :current_question, :players, :teams

    def initialize subject
      @subject = subject
      @players = []
      @teams   = subject['teams']
      reset
      super Channel.new
    end

    def id
      @id ||= Time.now.to_i
    end

    def questions
      [
        {id: 1, question: 'what is the capital of england?',    answer: 'london'},
        {id: 2, question: 'what is the capital of zambia?',     answer: 'lusaka'},
        {id: 3, question: 'what is the capital of australia?',  answer: 'canberra'},
      ]
    end

    def start_questions
      round_questions = questions
      @state = STATE_RUNNING
      @session ||= EM.add_periodic_timer(QUESTION_TIMEOUT) {
        @current_question[:closed] = true if @current_question

        if question = round_questions.shift
          @current_question = question
          notify Presenters::RoundUpdate.new(self).as_hash('round:question')
        else
          @state = STATE_COMPLETED
          notify Presenters::RoundUpdate.new(self).as_hash('round:completed')
          reset
        end
      }
    end

    def reset
      puts "INITIALIZING ROUND #{@subject}"
      EM.cancel_timer @session
      @scores   = teams.map {|t| {team: t, score: 0}}
      @session  = nil
      @state = STATE_READY
    end

    def register_player player, team
      players << {player: player, team: team}
      player.channel_subscriptions << {
        channel:        channel,
        sid:            subscribe(player.socket),
        on_unsubscribe: Proc.new { unregister_player player }
      }
    end

    def unregister_player player
      players.reject! {|p| p[:player] == player}
    end

    def team_for player
      return nil unless rec = players.find {|p| p[:player] == player}
      rec[:team]
    end

    def award_score(team, val)
      score = scores.find {|s| s[:team] == team}
      score[:score] += val
    end

    def answer player, question_id, answer
      return unless (question = questions.find {|q| q[:id] == question_id.to_i}) && (team = team_for(player))
      return unless state == STATE_RUNNING && !question[:closed]

      if question[:answer].downcase == answer.downcase
        award_score team, 1
        notify Presenters::RoundUpdate.new(self).as_hash
        true
      else
        false
      end
    end

    # could be more than one with the same score
    def winning_scores
      high_score = scores.max {|score| score[:score]}[:score]
      scores.select {|score| score[:score] == high_score}
    end

    def highest_player_score
    end
  end
end