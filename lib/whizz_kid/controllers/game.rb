class SocketController

  def self.routes
    @routes ||= []
  end

  def self.get(route, &block)
    p 'adding route', route
    route = {route: "get:#{route.downcase}", action: block}
    routes << route
  end

  def initialize(web_socket)
    @socket = web_socket
  end

  def route_for(request)
    self.class.routes.each {|r| p r[:route]}
    self.class.routes.first {|route| route[:route] == request.downcase}
  end

  def dispatch(request)
    route = route_for(request) or raise "Unknown Route '#{request}'"
    response = route[:action].call
    @socket.send response
  end
end

module WhizzKid
  module Controllers
    class Game < SocketController
      get 'test' do
        puts "CALLED Route"
        "blah"
      end
    end
  end
end