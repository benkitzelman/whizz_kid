window.App = window.App ? {}
window.App.Views = window.App.Views ? {}

class App.Views.TeamPromptView extends App.View
  className: 'team-prompt-view'
  template: _.template '''
  <p>Who do you support?</p>
  <form class='teams' />
  '''

  teamTemplate: _.template '''
  <div class='team'>
    <input id="<%= id %>-radio" type='radio' name='team' value='<%= id %>'/>
    <label for="<%= id %>-radio" id='<%= id %>-lbl'><%= name %></label>
  </div>
  '''

  events:
    'click input' : 'onTeamClicked'

  render: ->
    @$el.html @template(@collection)
    @$('.teams').append(@teamTemplate(team)) for team in @collection
    this

  onTeamClicked: ->
    val = @$("input[@name=team]:checked").val()
    @$("##{val}-lbl").addClass 'selected'

    _.delay =>
      @trigger 'team-selected', @$("input[@name=team]:checked").val()
    , 500
