require 'singleton'
module WhizzKid
  class Game < BaseObservable
    include Singleton

    def self.start
      instance.start
    end

    def start
      notify 'Game initialized'
      self
    end

    def join_or_create_round(contest)
      @round ||= Round.new(contest)
    end

  end
end