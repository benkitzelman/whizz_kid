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
    <div class='winners' />
  </div>
  '''


  initialize: (options = {}) ->
    super options
    @game = options.game
    @model?.on 'question-received', @renderQuestion, this
    @model?.on 'question-marked',   @renderQuestionMark, this
    @model?.on 'change:scores',     @renderScores, this
    # @model?.on 'change:state',      @onStateChange, this
    @model?.on 'change:scoreAssessment', @onAssessmentChange, this

  onAssessmentChange: ->
    console.log @model.get('scoreAssessment')

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

  renderRoundResults: ->
    @$el.html @resultsTemplate(@model.toJSON())
    @$('.winners').append(@scoreTemplate(@scoreContextFor score)) for score in @model.get('results').winning_scores

  onStateChange: ->
    return unless @model.get('state') == 'completed'
    @renderRoundResults()

