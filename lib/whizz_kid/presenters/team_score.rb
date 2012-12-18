module WhizzKid
  module Presenters
    class TeamScore
      def initialize team_score
        @team_score = team_score
      end

      def as_hash
        return if @team_score.nil?
        {
          team:           @team_score.team,
          player_scores:  @team_score.player_scores.map{|score| Presenters::PlayerScore.new(score).as_hash},
          total:          @team_score.total,
        }
      end
    end
  end
end