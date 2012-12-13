window.App ?= {}
class App.Router extends Backbone.Router
  routes:
    '': 'home'

  home: ->
    view = new App.Views.GameView(model: window.app.game)
    $('body').html view.render().el