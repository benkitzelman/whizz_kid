require 'singleton'
module WhizzKid
  class Game < BaseObservable
    include Singleton

    STATE_STARTED = :started
    STATE_PLAYING = :playing

    def self.start(channel)
      instance.start channel
    end

    def start(channel)
      @channel = channel
      @state = STATE_STARTED

      notify "game:#{@state}"
      self
    end

    def join_or_create_round(contest)
      puts "JOINING ROUND"

      @round ||= Round.new(channel, contest)
      @round.start_questions
      notify "game:joined:#{@round.id}"
    end

  end
end