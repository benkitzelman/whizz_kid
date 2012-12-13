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

      notify Presenters::GameUpdate.new(self).as_hash
      self
    end

    def rounds
      @rounds ||= []
    end

    def round_for(subject)
      rounds.find {|r| r.subject['name'] == subject['name']}
    end

    def join_or_create_round(subject, player, team)
      unless round = round_for(subject)
        puts "CREATING ROUND: #{subject.inspect}"
        round = Round.new(subject)
        return if round.questions.nil? || round.questions.empty?
        @rounds << round
      end

      puts "JOINING ROUND #{subject.inspect}"
      round.register_player player, team
      round.start_questions
      @state = STATE_PLAYING
      round
    end

    def player_connected ws
      player = WhizzKid::Player.new(ws)
      player.channel_subscriptions << {channel: channel, sid: subscribe(ws)}
      player
    end

  end
end