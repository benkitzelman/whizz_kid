class App.Game extends App.SocketObserver

  onServiceMessage: (command, data, msg) ->
    return unless command[0] == 'game'
    console.log 'GAME message from server', msg

    switch command[1]
      when 'ready'    then @joinRound()
      when 'joined'   then @createRound(data)
      when 'score'    then @updateScore(msg)

  onServiceConnection: ->

  onServiceClosed: ->

  joinRound: ->
    subject = {teams:[{id: 'manu', name: 'Manchester United'}, {id: 'ars', name: 'Arsenal'}]}
    stubbedContests = ['my-contest', 'my-contest-2', 'my-contest-3', 'my-contest-4']
    stubbedContests = ['my-contest']

    name         = stubbedContests[Date.now() % stubbedContests.length]
    selectedTeam = subject.teams[Date.now() % subject.teams.length]
    roundSubject = _.extend subject, {name: name, selected_team: selectedTeam}

    console.log "SELECTED TEAM:", selectedTeam
    @sendMessage "game:join", roundSubject

  createRound: (roundData)->
    @currentRound = new App.Round roundData, {socket: @socket}
    @trigger 'round-joined', @currentRound

  updateScore: (msg) ->
    console.log("SCORE:", msg[2])