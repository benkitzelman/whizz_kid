window.App = window.App ? {}
window.App.Views = window.App.Views ? {}

class App.Views.RoundView extends App.View
  @QUESTION_CORRECT_MSG   = ['You got it right!', 'PASS', 'You\'re a genius']
  @QUESTION_INCORRECT_MSG = ['You got it wrong!', 'FAIL', 'Incorrect']
  className: 'round-view'
  template: _.template '''
  <div class='subject'><b>Round:</b><span><%= subject.name %></span></div>
  <div class='scores' />
  <div class='timer'>Next question in <span></span> seconds</div>
  <div class='question-result' />
  <div class='question'>The game is about to start...</div>
  '''

  scoreTemplate: _.template '''
  <div class='score' id='<%= team.id %>'>
    <label><%= team.name %> <% if(isUsersTeam) {%> (your team)<% } %></label>
    <span><%= total || 0 %></span>
  </div>
  '''

  resultsTemplate: _.template '''
  <div class='round-complete'>
    <h3>Round Complete</h3>
    <a class='play-again-btn' href='#'>Play Again</a>
    <div class='winning-teams' />
    <div class='mvps' />
  </div>
  '''

  mvpTemplate: _.template '''
  <h5>MVP:</h5>
  <div><%= player.name %> (<%= total %>)</div>
  '''

  events:
    'click a.play-again-btn' : 'onPlayAgain'

  initialize: (options = {}) ->
    super options
    @game = options.game
    @model?.on 'question-received', @onNewQuestion, this
    @model?.on 'question-marked',   @renderQuestionMark, this
    @model?.on 'change:scores',     @renderScores, this
    @model?.on 'change:state',      @onStateChange, this
    @model?.on 'change:scoreAssessment', @onAssessmentChange, this

  scoreContextFor: (score) ->
    _.extend score, {isUsersTeam: score.team.id == @game.selectedTeam.id}

  render: ->
    @$el.html @template(@model.toJSON())
    @renderScores()
    @renderQuestion()
    @startTimer()
    this

  renderScores: ->
    @$('.scores').html ''
    @$('.scores').append(@scoreTemplate(@scoreContextFor score)) for score in @model.get('scores')

  startTimer: ->
    @timer ?= setInterval =>
      @restartTimer() if !@_qCountDown? or @_qCountDown == 0
      @$('.timer span').html (@_qCountDown -= 1)
    , 1000

  restartTimer: ->
    @_qCountDown = @game.get 'question_timeout'

  teams: ->
    @get('subject')?.teams

  renderQuestion: ->
    return unless question = @model.currentQuestion()

    @restartTimer()
    questionView = new App.Views.QuestionView(model: question)
    @$('.question').html questionView.render().el

  renderQuestionMark: (question)->
    response = if question.get('correct')
      RoundView.QUESTION_CORRECT_MSG[Date.now() % RoundView.QUESTION_CORRECT_MSG.length]
    else
      RoundView.QUESTION_INCORRECT_MSG[Date.now() % RoundView.QUESTION_INCORRECT_MSG.length]

    @$('.question-result').html response
    _.delay (=> @$('.question-result').html('')), 2000

  teamResult: ->
    contexts = _.map @model.get('results').winning_scores, (score)=> @scoreContextFor(score)
    return "lost" unless !!_.find(contexts, ((c)-> c.isUsersTeam))
    return "draw" if contexts.length > 1
    "win"

  renderRoundResults: ->
    @$el.html @resultsTemplate(@model.toJSON())
    result = switch @teamResult()
      when "win" then 'Your Team Won!'
      when "lost" then "Your Team Lost"
      else 'Draw'

    @$('.winning-teams').append "<h4>#{result}</h4>"
    @$('.winning-teams').append(@scoreTemplate(@scoreContextFor score)) for score in @model.get('results').winning_scores
    @$('.mvps').append @mvpTemplate(mvp) if mvp = @model.get('results').highest_player_score

    if @teamResult() == "win"
      @notifySound = new Audio("/audio/win.mp3")
      @notifySound.play()

  onStateChange: ->
    return unless @model.get('state') == 'completed'
    @renderRoundResults()

  onAssessmentChange: ->
    console.log @model.get('scoreAssessment')
    # if @model.get('scoreAssessment') == 'small-lead'

  onNewQuestion: ->
    @renderQuestion()
    @notifySound = new Audio("/audio/click.mp3")
    @notifySound.play()

  onPlayAgain: (e) ->
    e?.preventDefault()
    e?.stopPropagation()
    @game.joinRound()