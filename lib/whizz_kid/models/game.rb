require 'singleton'
module WhizzKid
  class Game < BaseObservable
    include Singleton

    STATE_STARTED = :started
    STATE_PLAYING = :playing

    def self.start
      instance.start
    end

    def start
      @state = STATE_STARTED

      notify "game:#{@state}"
      self
    end

    def join_or_create_round(contest)
      puts "JOINING ROUND"

      @round ||= Round.new(observers, contest)
      @round.start_questions
      notify "game:joined:#{@round.id}"
    end

  end
end