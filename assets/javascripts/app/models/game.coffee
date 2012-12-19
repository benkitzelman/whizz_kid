class App.Game extends App.SocketObserver

  initialize: (args...) ->
    @teams = @teamsFromUrl()
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

  teamsFromUrl: ->
    return unless match = document.location.search.match(/teams=([^&]*).*/)

    teamStr = unescape match[1]
    teamStr = teamStr.replace(/\\/g, "")
    JSON.parse teamStr

  topicsFromUrl: ->
    return unless match = document.location.search.match(/topics=([^&]*).*/)

    topicStr = unescape match[1]
    topicStr = topicStr.replace(/\\/g, "")
    JSON.parse topicStr

  nameFromUrl: ->
    unescape(match[1]) if match = document.location.search.match(/name=([^&]*).*/)

  subject: ->
    {name: @nameFromUrl(), topics: @topicsFromUrl(), teams: @teams, selected_team: @selectedTeam}

  joinRound: ->
    return unless @selectedTeam?

    console.log @subject()
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

