module WhizzKid
  module Web
    class APIController < WhizzKid::Web::BaseController
      helpers do
        def context
          Context.new(request)
        end
      end

      def subject
        @subject ||= Subject.fetch context
      end

      def can_service_request?
        context.is_supported? && subject && !subject.topics.empty? && Game.instance.can_service(subject)
      end

      #tiles.json?competition=competition-26&locale=en-GB&region=AU&section_type=competition&sport=football&sports=sports&subject_uid=competition-26&subject_url=http%3A%2F%2Flocalhost%3A8080%2Fsportsdata%2Fcompetitions%2F26
      get '/tiles.json' do
        p request.url
        content_type 'application/json'
        halt 200, [].to_json unless can_service_request?

        Presenters::Subject.new(subject).as_tiles.to_json
      end
    end
  end
end