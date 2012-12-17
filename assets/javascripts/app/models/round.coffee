class App.Round extends App.SocketObserver

  initialize: (args...) ->
    @receivedQuestions = []
    @on 'change:current_question', @_onNewQuestion, this
    super args...

  onServiceMessage: (command, data, msg) ->
    super command, data, msg

    return unless command[0] == 'round'
    @set data

  currentQuestion: ->
    _.last(@receivedQuestions) or null

  _onNewQuestion: ->
    return unless question = @get('current_question')

    question = new App.Question(question, {round: this})
    question.on 'change:correct', @_onQuestionMarked, this

    @receivedQuestions.push question
    @trigger 'question-received', this, question

  _onQuestionMarked: (question) ->
    @assessScoreDifference()
    @trigger 'question-marked', question

  teamScore: ->
    _.find(@get('scores'), (s) -> s.isUsersTeam) ? {total: 0}

  winningTeam: (fromTeams) ->
    scores = fromTeams ? @get('scores')
    _.max(scores, (s) -> s.total)

  assessScoreDifference: ->
    return unless team = @teamScore()
    otherTeams = _.reject @get('scores'), ((score) -> score == team)
    difference = (team.total - @winningTeam(otherTeams)?.total)

    if difference > 1   then assessment = "small-lead"
    if difference > 5   then assessment = "big-lead"
    if difference < -1  then assessment = "small-loss"
    if difference < -5  then assessment = "big-loss"
    @set(scoreAssessment: assessment ? 'even')

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