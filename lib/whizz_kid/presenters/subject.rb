require 'uuid'

module WhizzKid
  module Presenters
    class Subject
      def initialize subject
        @subject = subject
      end

      def as_tiles
        [{
          :':type'  => "application/vnd.playup.extension+json",
          :':uid'   => @subject.cache_key,
          :name     => @subject.title,

          :':display' => {
            :':type'          => "application/vnd.playup.display.tile.solid+json",
            :title            => @subject.title,
            :background_color => "0x5893CE",
            :background_image => [
              {
                density: "low",
                href: "http://s3-us-west-2.amazonaws.com/playup-tms/organization_1/images/question_mark.png"
              },
              {
                density: "high",
                href: "http://s3-us-west-2.amazonaws.com/playup-tms/organization_1/images/question_mark.png"
              },
              {
                density: "medium",
                href: "http://s3-us-west-2.amazonaws.com/playup-tms/organization_1/images/question_mark.png"
              }
            ],
            :footer_title => "",
            :footer_subtitle => ""
          },

          :link => {
            :':self' => @subject.game_url,
            :':type' => "text/html"
          }
        }]
      end
    end
  end
end