window.App = window.App ? {}
window.App.Views = window.App.Views ? {}

class App.View extends Backbone.View


class App.Views.GameView extends App.View
  template: _.template '''
  <h1>Whizz Kid</h1>
  '''

  initialize: (options = {}) ->
    @model.on 'round-joined', @renderRound, this
    super options

  render: ->
    @$el.html @template()
    @renderRound()
    this

  renderRound: ->
    return unless @model?.currentRound?

    @roundView = new App.Views.RoundView(model: @model.currentRound)
    @$el.append @roundView.render().el

class App.Views.RoundView extends App.View
  template: _.template '''
  <div class='subject'><b>Round:</b><span><%= subject.name %></span></div>
  <div class='scores' />
  <div class='question' />
  '''

  scoreTemplate: _.template '''
  <div class='score'>
    <label><%= team.name %></label>
    <span><%= score || 0 %></span>
  </div>
  '''

  initialize: (options = {}) ->
    super options
    @model?.on 'question-received', @renderQuestion, this
    @model?.on 'change:scores', @render, this

  render: ->
    @$el.html @template(@model.toJSON())
    @$('.scores').append(@scoreTemplate(score)) for score in @model.get('scores')
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
