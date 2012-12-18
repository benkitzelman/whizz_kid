class App.Question extends App.Model
  initialize: (attrs, options = {}) ->
    @round = options.round
    super attrs, options

  type: ->
    if @has('options') then 'mc' else 'text'

  answer: (answer)->
    @set(answer: answer)
    @round.sendRequest("round:#{@round.id}:question:#{@get 'id'}:answer:#{answer}")
      .pipe (command, data, msg) =>
        @set(correct: data)