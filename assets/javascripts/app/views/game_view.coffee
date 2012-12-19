window.App = window.App ? {}
window.App.Views = window.App.Views ? {}

class App.Views.GameView extends App.View
  className: 'game-view'
  template: _.template '''
  <header>
    <h1>Whizz Kid</h1>
  </header>
  <div class='game-content' />
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
    @$('.game-content').html @roundView.render().el

  renderTeamPrompt: ->
    @teamView = new App.Views.TeamPromptView(collection: @model.teams)
    @teamView.on 'team-selected', @onTeamSelected, this
    @$('.game-content').html @teamView.render().el

  onStateChange: ->
    @model.get('state') == 'ready'

  onTeamSelected: (teamId) ->
    return unless team = _.detect(@model.teams, (t)-> t.id == teamId)
    @model.selectedTeam = team
    console.log 'SELECTED:', @model.selectedTeam
    @model.joinRound()
    @teamView.remove()

