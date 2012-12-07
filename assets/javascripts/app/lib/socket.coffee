class App.Socket
  @connect: ->
    @_socket = new App.Socket("ws://localhost:8080")
    @_socket.connect()

  constructor: (socketAddress) ->
    @address = socketAddress

  debug: (args...) ->
    console.log args...

  connect: ->
    @_ws = new WebSocket @address
    @_ws.onmessage = (evt) => 
      @debug 'MSG:', evt, evt.data

    @_ws.onclose = =>
      @debug "socket closed"

    @_ws.onopen = =>
      @debug "connected..."
      @_ws.send "game:state"
    this

  disconnect: ->
    @_ws.onmessage  = null
    @_ws.onclose    = null
    @_ws.onopen     = null
    delete @_ws

