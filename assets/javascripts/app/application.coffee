window.App ?= {}
class App.Application
  _.extend @prototype, Backbone.Events

  constructor: ->
    window.app = this

  start: ->
    @game = new App.Game
    @game.on 'no-rounds', @_onNoRoundsForSubject, this
    @router = new App.Router
    Backbone.history.start()
    @game.canCreateRoundForSubject()

  _onNoRoundsForSubject: ->
    console.warn 'No questions were found for the given subject'