window.App ?= {}
class App.Application
  _.extend @prototype, Backbone.Events

  constructor: ->
    window.app = this

  start: ->
    @router = new App.Router
    @game = new App.Game
    @game.on 'no-rounds', @_onNoRoundsForSubject, this
    Backbone.history.start()
    console.log 'ready to go...'

  _onNoRoundsForSubject: ->
    console.warn 'No questions were found for the given subject'