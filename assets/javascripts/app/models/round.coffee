class App.Round extends App.SocketObserver

  initialize: (args...) ->
    super args...
    @receivedQuestions = []
    @_onNewQuestion()
    @on 'change:current_question', @_onNewQuestion, this

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
