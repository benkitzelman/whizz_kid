window.App ?= {}
class App.Application
  _.extend @prototype, Backbone.Events

  constructor: ->
    window.app = this

  start: ->
    @router = new App.Router
    @game = new App.Game
    Backbone.history.start()
    console.log 'ready to go...'