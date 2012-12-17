class App.Game extends App.SocketObserver

  initialize: (args...) ->
    @teams = [{id: 'team-1', name: 'Manchester United'}, {id: 'team-2', name: 'Arsenal'}]
    @state = 'uninitialized'
    super args...

  onServiceMessage: (command, data, msg) ->
    super command, data, msg

    return unless command[0] == 'game'
    @set data

  onServiceError: (error) ->
    if /no-rounds/.test(error.error)
      @trigger 'no-rounds', this

  onServiceConnection: ->

  onServiceClosed: ->

  subject: ->
    subject = {teams: @teams, topics: ['test']}
    stubbedContests = ['my-contest', 'my-contest-2', 'my-contest-3', 'my-contest-4']
    # stubbedContests = ['my-contest']

    name         = stubbedContests[Date.now() % stubbedContests.length]
    _.extend subject, {name: name, selected_team: @selectedTeam}

  joinRound: ->
    return unless @selectedTeam?

    @sendRequest("game:join", @subject())
      .pipe (command, data, msg) =>
        @createRound data

      .fail (args...) ->
        console.warn args...


  createRound: (roundData)->
    @currentRound = new App.Round roundData, {socket: @socket}
    @trigger 'round-joined', @currentRound

  canCreateRoundForSubject: ->
    @sendRequest('game:can-service', @subject())
      .pipe (command, canService, msg) ->
        console.log "The game #{if canService then 'CAN' else 'CANNOT'} service this subject"
        canService

