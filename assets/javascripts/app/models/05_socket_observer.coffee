class App.SocketObserver extends App.Model
  initialize: (attrs, options = {}) ->
    @socket = options.socket ? App.Socket.connect()
    @socket.attachListener this
    super

  setSocket: (socket) ->
    @socket = socket

  sendMessage: (command, data) ->
    msg = {command: command, data: (data or @toJSON())}
    console.log 'sending to server', msg
    @socket?.send JSON.stringify msg