#tiles.json?competition=competition-26
#&locale=en-GB
#&region=AU
#&section_type=competition
#&sport=football
#&sports=sports
#&subject_uid=competition-26
#&subject_url=http%3A%2F%2Flocalhost%3A8080%2Fsportsdata%2Fcompetitions%2F26
module WhizzKid
  class Context
    def initialize(request)
      @params  = request.params
      @request = request
    end

    # King of all HACKS - I don't want to do the Auth dance (time) with API - so I'll use the public SD API
    def subject_url
      return unless (api_url = @params['subject_url']) && proxied_url = api_url.match(/.+sportsdata\/(.+)/)
      "#{WhizzKid.settings.sports_data_url}/#{proxied_url[1]}"
    end

    def is_supported?
      @params['subject_url'] =~ /\/contests\/(\d+)$/
    end
  end
end