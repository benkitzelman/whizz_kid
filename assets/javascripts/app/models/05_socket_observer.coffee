class App.SocketObserver extends App.Model
  initialize: (attrs, options = {}) ->
    @socket = options.socket ? App.Socket.connect()
    @socket.attachListener this
    @_requests = []
    super

  setSocket: (socket) ->
    @socket = socket

  sendMessage: (command, data) ->
    msg = {command: command, data: (data or @toJSON())}
    console.log 'sending to server', msg
    @socket.connected.pipe =>
      @socket?.send JSON.stringify msg

  sendRequest: (command, data) ->
    msg = {command: command, data: (data or @toJSON())}
    request = @_addRequest command
    @socket.connected.pipe =>
      console.log 'SENDING REQUEST', msg
      @socket?.send JSON.stringify msg
    request

  _addRequest: (command) ->
    return request if request = @_requestFor(command)
    @_requests.push(command: command, request: (req = new $.Deferred))
    req

  _requestFor: (command) ->
    if req = _.detect(@_requests, ((r)-> r.command == command))
      return req.request

  _resolveRequest: (command, data, msg) ->
    return unless request = @_requestFor(command.join(':'))

    request.resolve command, data, msg
    @_requests = _.reject @requests, ((r)-> r.command == command)

  onServiceMessage: (command, data, msg) ->
    @_resolveRequest(command, data, msg)