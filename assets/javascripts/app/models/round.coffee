class App.Round extends App.SocketObserver

  onServiceMessage: (msg) ->
    return unless msg[0] == 'round'
    console.log 'ROUND message from server', msg

    switch msg[1]
      when 'question' then @onQuestion(msg)

  onQuestion: (msg) ->
    id = msg[2]
    @sendMessage "round:#{@id}:question:#{id}:answer:canberra"