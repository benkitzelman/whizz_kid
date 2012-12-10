class App.Model extends Backbone.Model

class App.SocketObserver extends App.Model
  initialize: (attrs, options = {}) ->
    @socket = options.socket ? App.Socket.connect()
    @socket.attachListener this
    super

  setSocket: (socket) ->
    @socket = socket

  sendMessage: (msg) ->
    console.log 'sending to server', msg
    @socket?.send msg