module WhizzKid
  def self.start
    EventMachine.run {
      @game = WhizzKid::Game.start(Channel.new)

      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|

        ws.onopen {
          player = @game.player_connected ws

          ws.onclose    { player.unsubscribe_all }
          ws.onmessage  {|msg| WhizzKid::Controllers::Game.new(@game, player).dispatch msg }

          player.send_message Presenters::GameUpdate.new(@game).as_hash('game:ready')
        }
      end
    }
  end

  def self.root
    File.join File.dirname(__FILE__), '../'
  end
end
