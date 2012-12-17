window.App = window.App ? {}
window.App.Views = window.App.Views ? {}

class App.View extends Backbone.View


class App.Views.GameView extends App.View
  template: _.template '''
  <h1>Whizz Kid</h1>
  '''

  initialize: (options = {}) ->
    @model.on 'round-joined', @renderRound, this
    @model.on 'change:state', @onStateChange, this
    super options

  render: ->
    @$el.html @template()
    if @model.selectedTeam?
      @renderRound()
    else
      @renderTeamPrompt()
    this

  renderRound: ->
    return unless @model?.currentRound?

    @roundView = new App.Views.RoundView(model: @model.currentRound, game: @model)
    @$el.append @roundView.render().el

  renderTeamPrompt: ->
    @teamView = new App.Views.TeamPromptView(collection: @model.teams)
    @teamView.on 'team-selected', @onTeamSelected, this
    @$el.append @teamView.render().el

  onStateChange: ->
    @model.get('state') == 'ready'

  onTeamSelected: (teamId) ->
    return unless team = _.detect(@model.teams, (t)-> t.id == teamId)
    @model.selectedTeam = team
    console.log 'SELECTED:', @model.selectedTeam
    @model.joinRound()
    @teamView.remove()

class App.Views.TeamPromptView extends App.View
  template: _.template '''
  <p>Who do you support?</p>
  <form class='teams' />
  '''

  teamTemplate: _.template '''
  <div class='team'>
    <input type='radio' name='team' value='<%= id %>'/>
    <label><%= name %></label>
  </div>
  '''

  events:
    'click input' : 'onTeamClicked'

  render: ->
    @$el.html @template(@collection)
    @$('.teams').append(@teamTemplate(team)) for team in @collection
    this

  onTeamClicked: ->
    @trigger 'team-selected', @$("input[@name=team]:checked").val()

class App.Views.RoundView extends App.View
  @QUESTION_CORRECT_MSG   = ['You got it right!', 'PASS', 'You\'re a genius']
  @QUESTION_INCORRECT_MSG = ['You got it wrong!', 'FAIL', 'Incorrect']

  template: _.template '''
  <div class='subject'><b>Round:</b><span><%= subject.name %></span></div>
  <div class='scores' />
  <div class='timer'>Next question in <span></span> seconds</div>
  <div class='question-result' />
  <div class='question'>The game is about to start...</div>
  '''

  scoreTemplate: _.template '''
  <div class='score'>
    <label><%= team.name %> <% if(isUsersTeam) {%> (your team)<% } %></label>
    <span><%= total || 0 %></span>
  </div>
  '''

  resultsTemplate: _.template '''
  <div class='rond-complete'>
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
    @model?.on 'change:state',      @onStateChange, this
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

class App.Views.QuestionView extends App.View
  tagName: 'form'
  textTemplate: _.template '''
  <b><%= question %></b>
  <input type='text' placeholder='Enter your answer....' />
  <button>Answer</button>
  '''

  mcTemplate: _.template '''
  <b><%= question %></b>
  <% for(var i=0; i< options.length; i++) { var option = options[i]; %>

  <input type='radio' name='answer' value='<%= option %>' />
  <label><%= option %></label>

  <% } %>
  '''

  answeredTemplate: _.template '''
  <b><%= question %></b>
  <div><label>Your answer: </label><span><%= answer %></span></div>
  '''

  events:
    'submit'                    : '_onSubmit'
    'click button'              : '_onSubmit'
    'click input[type="radio"]' : "_onSubmit"

  render: ->
    if @model.has('answer')
      @$el.html @answeredTemplate(@model.toJSON())
    else
      @$el.html @["#{@model.type()}Template"](@model.toJSON())
    this

  _onSubmit: (e) ->
    e?.preventDefault()
    e?.stopPropagation()

    selector = if @model.type() == 'mc' then "input[@name='answer']:checked" else 'input'
    return unless val = @$(selector).val()
    @model.answer(val)
    @render()
