require 'singleton'
require 'set'

module WhizzKid
  class Game < BaseObservable
    include Singleton

    STATE_STARTED = :started
    STATE_PLAYING = :playing

    def self.start(channel = nil)
      instance.start (channel || Channel.new)
    end

    def start(channel)
      @channel = channel
      @state   = STATE_STARTED

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
      Round.can_service? subject
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

    def add_player player
      subscription = subscribe player.socket
      player.channel_subscriptions << {channel: channel, sid: subscription}
      player
    end

    def remove_player player
      player.unsubscribe_all
    end
  end
end