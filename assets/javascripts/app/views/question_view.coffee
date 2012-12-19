window.App = window.App ? {}
window.App.Views = window.App.Views ? {}

class App.Views.QuestionView extends App.View
  className: 'question-view'
  tagName: 'form'
  textTemplate: _.template '''
  <b><%= question %></b>
  <input type='text' placeholder='Enter your answer....' />
  <button>Answer</button>
  '''

  mcTemplate: _.template '''
  <b><%= question %></b>
  <% for(var i=0; i< options.length; i++) { var option = options[i]; %>

  <div class='options'>
    <input type='radio' name='answer' id="<%= option %>-btn" value='<%= option %>' />
    <label for="<%= option %>-btn" id="<%= option %>-lbl"><%= option %></label>
  </div>

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
    @$("##{val}-lbl").addClass 'selected'

    _.delay =>
      @model.answer(val)
      @render()
    , 500
