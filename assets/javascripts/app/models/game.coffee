class App.Game extends App.SocketObserver

  onServiceMessage: (msg) ->
    return unless msg[0] == 'game'
    console.log 'GAME message from server', msg

    switch msg[1]
      when 'started' then @joinRound()
      when 'joined' then @createRound(msg[2])

  onServiceConnection: ->

  onServiceClosed: ->

  joinRound: ->
    @sendMessage('game:join:my-contest')

  createRound: (id)->
    @currentRound = new App.Round({id: id}, {socket: @socket})