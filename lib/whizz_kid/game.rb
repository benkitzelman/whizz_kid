require 'singleton'
require 'set'

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
      rounds.find do |r| 
        r.subject['name'] == subject['name'] && Set.new(r.subject['topics']) == Set.new(subject['topics']) && Set.new(r.subject['teams']) == Set.new(subject['teams'])
      end
    end

    def can_service(subject)
      round = Round.new(subject)
      !round.questions.nil? && !round.questions.empty?
    end

    def join_or_create_round(subject, player, team)
      unless round = round_for(subject)
        return unless can_service(subject)

        puts "CREATING ROUND: #{subject.inspect}"
        round = Round.new(subject)
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