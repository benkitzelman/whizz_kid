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
  template: _.template '''
  <div class='subject'><b>Round:</b><span><%= subject.name %></span></div>
  <div class='scores' />
  <div class='question' />
  '''

  scoreTemplate: _.template '''
  <div class='score'>
    <label><%= team.name %> <% if(isUsersTeam) {%> (your team)<% } %></label>
    <span><%= score || 0 %></span>
  </div>
  '''

  initialize: (options = {}) ->
    super options
    @game = options.game
    @model?.on 'question-received', @renderQuestion, this
    @model?.on 'change:scores', @render, this

  scoreContextFor: (score) ->
    _.extend score, {isUsersTeam: score.team.id == @game.selectedTeam.id}

  render: ->
    @$el.html @template(@model.toJSON())
    @$('.scores').append(@scoreTemplate(@scoreContextFor score)) for score in @model.get('scores')
    @renderQuestion()
    this

  teams: ->
    @get('subject')?.teams

  renderQuestion: ->
    return unless question = @model.currentQuestion()
    questionView = new App.Views.QuestionView(model: question)
    @$('.question').html questionView.render().el

class App.Views.QuestionView extends App.View
  tagName: 'form'
  template: _.template '''
  <b><%= question %></b>
  <input type='text' placeholder='Enter your answer....' />
  <button>Answer</button>
  '''

  events:
    'submit'        : '_onSubmit'
    'click button'  : '_onSubmit'

  render: ->
    @$el.html @template(@model.toJSON())
    this

  _onSubmit: (e) ->
    e?.preventDefault()
    e?.stopPropagation()
    return unless val = @$('input').val()
    @model.answer(val)
