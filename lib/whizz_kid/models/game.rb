require 'singleton'
module WhizzKid
  class Game < BaseObservable
    include Singleton

    def self.start(web_socket)
      instance.start(web_socket)
    end

    def start(web_socket)
      @notifier = web_socket
      
      notify 'Game initialized'
      self
    end
  end
end