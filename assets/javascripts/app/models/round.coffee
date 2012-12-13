class App.Round extends App.SocketObserver

  initialize: (args...) ->
    @receivedQuestions = []
    super args...

  onServiceMessage: (command, data, msg) ->
    return unless command[0] == 'round'
    console.log 'ROUND message from server', command, data
    @set data

    switch command[1]
      when 'question' then @onQuestion(@get 'current_question')

  currentQuestion: ->
    _.last(@receivedQuestions) or null

  onQuestion: (question) ->
    return unless question?

    question = new App.Question({id: question.id, question: question.question}, {round: this})
    @receivedQuestions.push question
    @trigger 'question-received', this, question

class App.Question extends App.Model
  initialize: (attrs, options = {}) ->
    @round = options.round
    super attrs, options

  answer: (answer)->
    @set(answer: answer)
    @round.sendMessage "round:#{@round.id}:question:#{@get 'id'}:answer:#{answer}"