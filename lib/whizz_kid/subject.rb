require 'httparty'
require 'json'
require 'uri'

module WhizzKid
  class Subject
    def self.fetch context
      return unless url = context.subject_url

      response = HTTParty.get url
      return nil if response.code != 200

      subject = Subject.new(JSON.parse response.parsed_response)
    end

    def initialize(data)
      @data = data
    end

    def cache_key
      "trivia-#{@data[':uid']}"
    end

    def game_url
      team_param = teams.map {|t| "#{t[:id]}_#{t[:name]}" }.join('__')
      topics_param = topics.join('_')
      "#{WhizzKid.settings.root_url}?name=#{URI.encode title}&topics=#{URI.encode topics_param}&teams=#{URI.encode team_param}"
    end

    def title
      @data['title'] || 'Game Trivia'
    end

    def topics
      topics = can_be_topic? ? [ @data[':uid'] ] : []
      return topics if ancestors.nil?

      topics + ancestors.reduce([]) {|list, ancestor| can_be_topic?(ancestor) ? (list << ancestor[':uid']) : list}
    end

    def teams
      @data['scores'].map do |s|
        {
          id: s['team'][':uid'],
          name: s['team']['name']
        }
      end
    end

    def [] property
      method = property.to_sym
      send(method) if respond_to? method
    end

    private

    def ancestors
      @data['ancestors']
    end

    def can_be_topic? resource = @data
      %w{sport team competition}.any? {|type| resource[':type'] =~ %r{application\/vnd\.playup\.sport\.#{type}(\.|\+)(.*)json} }
    end
  end
end