module WhizzKid
  class << self

    def root
      Pathname.new(File.dirname(__FILE__)) + '../'
    end

    def compiled_path
      Pathname.new(root) + 'compiled'
    end

    def environment
      (ENV['RACK_ENV'] || :development).to_sym
    end

    def settings
      @settings ||= WhizzKid::Config::AppConfig.new
    end

    def start_game_server
      EventMachine.run {
        @game = WhizzKid::Game.start(Channel.new)

        EventMachine::WebSocket.start(:host => '0.0.0.0', :port => WhizzKid.settings.web_socket_port) do |ws|

          ws.onopen {
            player = @game.player_connected ws

            ws.onclose    { player.unsubscribe_all }
            ws.onmessage  {|msg| WhizzKid::Controllers::Game.new(@game, player).dispatch msg }

            player.send_message Presenters::GameUpdate.new(@game).as_hash('game:ready')
          }
        end
      }
    end

  end # self
end # WhizzKid
