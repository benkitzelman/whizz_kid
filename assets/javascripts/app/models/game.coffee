class App.Game extends App.SocketObserver

  onServiceMessage: (msg) ->
    return unless msg[0] == 'game'
    console.log 'GAME message from server', msg

    switch msg[1]
      when 'started'  then @joinRound()
      when 'joined'   then @createRound(msg[2])
      when 'score'    then @updateScore(msg)

  onServiceConnection: ->

  onServiceClosed: ->

  joinRound: ->
    stubbedContests = ['my-contest', 'my-contest-2', 'my-contest-3', 'my-contest-4']
    index = Date.now() % stubbedContests.length
    @sendMessage("game:join:#{stubbedContests[index]}")

  createRound: (id)->
    @currentRound = new App.Round({id: id}, {socket: @socket})

  updateScore: (msg) ->
    console.log("SCORE:", msg[2])