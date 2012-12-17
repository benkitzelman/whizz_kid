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
      @question_topics = subject['topics'] || []
      reset
      super Channel.new
    end

    def id
      @id ||= Time.now.to_i
    end

    def questions
      @questions ||= Question.list_for_topics(@question_topics)
    end

    def start_questions
      round_questions = questions.dup
      @state = STATE_RUNNING
      @session ||= EM.add_periodic_timer(QUESTION_TIMEOUT) {
        @current_question.closed = true if @current_question

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
      EM.cancel_timer @session
      @scores     = teams.map {|t| TeamScore.new(t) }
      @session    = nil
      @questions  = nil
      @state      = STATE_READY
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

    def answer player, question_id, answer
      return unless question = questions.find {|q| q.id == question_id}
      return unless state == STATE_RUNNING && !question.closed

      if question.answer.to_s.downcase == answer.downcase
        award_score_for question, player, 1
        notify Presenters::RoundUpdate.new(self).as_hash
        true
      else
        false
      end
    end

    def award_score_for(question, player, val)
      team        = team_for player
      team_score  = scores.find {|s| s.team == team}
      team_score.award player, question, val
    end

    def score_for team
      team        = team_for player
      team_score  = scores.find {|s| s.team == team}
    end

    # could be more than one team with the same score
    def winning_scores
      high_score = scores.max{|score| score.total}.total
      scores.select {|score| score.total == high_score}
    end

    def highest_player_score
      scores.reduce({player: nil, total: 0}) do |highest_scorer, team_score|
        scorer = team_score.highest_scorer
        (scorer[:total] > highest_scorer[:total]) ? scorer : highest_scorer
      end
    end
  end
end