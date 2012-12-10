window.App ?= {}
class App.Application
  start: ->
    @router = new App.Router
    Backbone.history.start()
    @game = new App.Game
    console.log 'ready to go...'