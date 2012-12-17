class App.Socket
  @connect: ->
    @_socket = new App.Socket("ws://localhost:8080")
    @_socket.connect()

  constructor: (socketAddress) ->
    @address = socketAddress
    @connected = new $.Deferred

  debug: (args...) ->
    console.log args...

  listeners: ->
    @_listeners ?= []

  attachListener: (listener) ->
    @listeners().push listener

  detatchListener: (listener) ->
    @_listeners = _.reject @listeners(), (l) -> _.isEqual(l, listeners)

  connect: ->
    if @connected.isResolved() or @connected.isRejected()
      @connected = new $.Deferred

    @_ws = new WebSocket @address
    listener.setSocket(@_ws) for listener in @listeners()

    @_ws.onmessage = (evt) =>
      message = JSON.parse evt.data
      if message.error?
        listener.onServiceError?(message) for listener in @listeners()
      else
        listener.onServiceMessage?(message.command.split(':'), message.data, evt) for listener in @listeners()

    @_ws.onclose = =>
      @debug "socket closed"
      listener.onServiceClose?() for listener in @listeners()

    @_ws.onopen = =>
      @connected.resolve this
      @debug "connected..."
      listener.onServiceConnect?() for listener in @listeners()
    this

  disconnect: ->
    @connected      = new $.Deferred
    @_ws.onmessage  = null
    @_ws.onclose    = null
    @_ws.onopen     = null
    delete @_ws

  send: (message) ->
    @_ws?.send message