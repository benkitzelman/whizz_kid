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

    def rounds
      @rounds ||= []
    end

    def round_for(contest)
      rounds.find {|r| r.contest == contest}
    end

    def join_or_create_round(contest, ws)
      unless round = round_for(contest)
        puts "CREATING ROUND: #{contest}"
        round = Round.new(contest)
        @rounds << round
      end

      puts "JOINING ROUND #{contest}"
      round.subscribe ws
      round.start_questions
      round
    end

    def unsubscribe ws
      rounds.each{|r| r.unsubscribe ws}
      super ws
    end
  end
end