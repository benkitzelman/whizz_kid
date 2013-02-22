require_relative '../support/spec_helper'

module WhizzKid
  describe Game do

    context 'class methods' do
      context 'start' do
        let(:started_msg) { JSON.generate(command: 'game:update', data: {state: Game::STATE_STARTED, question_timeout: 10}) }

        it 'should return an instance' do
          Game.start(double('channel', push: nil)).should be_a(Game)
        end
      end
    end

    context 'instance methods' do
      subject(:game) { Game.instance }

      context 'start' do
        let(:started_msg) { JSON.generate(Presenters::GameUpdate.new(game).as_hash) }

        it 'should return an instance' do
          game.start(double('channel', push: nil)).should be_a(Game)
        end

        it 'should push a ready message onto the channel' do
          channel = double('channel')
          channel.should_receive(:push).with started_msg
          Game.start channel
        end

        it 'should set "started" state' do
          Game.start
          game.state.should eq Game::STATE_STARTED
        end
      end

      context 'after started' do
        let(:new_subject)      { {'name' => 'new test', 'topics' => ['blah'], 'teams' => ['wibble', 'fish']} }
        let(:existing_subject) { {'name' => 'test', 'topics' => ['gerald', 'cindy lauper'], 'teams' => ['hermans hermits', 'johns miraculous turnip']} }
        let(:player)           { 'player' }
        let(:team)             { 'wibble' }

        before do
          EM.stub(:cancel_timer)
          game.rounds << Round.new(existing_subject)
        end

        after do
          game.rounds.clear
        end

        context 'round_for' do
          it 'should return nil if round for subject hasn\'t started' do
            game.round_for(new_subject).should be_nil
          end

          it 'should return a round matching the given subject' do
            game.round_for(existing_subject).should be_a(Round)
          end
        end

        context 'join_or_create_round' do
          context 'if the subject can be serviced' do
            let (:round) { double 'round' }

            before do
              Round.stub(:new).and_return round
              Round.stub(:can_service?).and_return true
              round.should_receive(:register_player).with(player, team)
              round.should_receive(:start_questions)
            end

            it 'should create a round if round not found for subject' do
              rnd = game.join_or_create_round new_subject, player, team
              rnd.should eq round
            end

            it 'should add the round to the game\'s rounds list' do
              rnd = game.join_or_create_round new_subject, player, team
              game.rounds.should be_include(rnd)
            end

            it 'should change the game state to playing' do
              game.join_or_create_round new_subject, player, team
              game.state.should eq Game::STATE_PLAYING
            end
          end

          context 'if the subject cannot be serviced' do
            it 'should return nil' do
              round = game.join_or_create_round new_subject, player, team
              round.should be_nil
            end
          end
        end

        context 'player registration' do
          let(:player)  { double 'player' }

          before do
            @subscriptions = []
            player.stub(:socket).and_return 'socket'
            player.stub(:channel_subscriptions).and_return @subscriptions
            game.channel.stub(:subscribe).and_return(123)
          end

          it 'should subscribe a player to the game channel' do
            game.add_player(player).should eq player
            @subscriptions.should be_include(channel: game.channel, sid: 123)
          end

          it 'should unsubscribe a player from all channels' do
            player.should_receive(:unsubscribe_all).once
            game.remove_player player
          end
        end
      end
    end
  end
end