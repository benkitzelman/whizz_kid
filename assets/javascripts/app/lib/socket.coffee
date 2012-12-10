class App.Socket
  @connect: ->
    @_socket = new App.Socket("ws://localhost:8080")
    @_socket.connect()

  constructor: (socketAddress) ->
    @address = socketAddress

  debug: (args...) ->
    console.log args...

  listeners: ->
    @_listeners ?= []

  attachListener: (listener) ->
    @listeners().push listener

  detatchListener: (listener) ->
    @_listeners = _.reject @listeners(), (l) -> _.isEqual(l, listeners)

  connect: ->
    @_ws = new WebSocket @address
    listener.setSocket(@_ws) for listener in @listeners()

    @_ws.onmessage = (evt) =>
      data = evt.data.split(':')
      listener.onServiceMessage?(data, evt) for listener in @listeners()

    @_ws.onclose = =>
      @debug "socket closed"
      listener.onServiceClose?() for listener in @listeners()

    @_ws.onopen = =>
      @debug "connected..."
      listener.onServiceConnect?() for listener in @listeners()
    this

  disconnect: ->
    @_ws.onmessage  = null
    @_ws.onclose    = null
    @_ws.onopen     = null
    delete @_ws

  send: (message) ->
    @_ws?.send message