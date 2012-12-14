module WhizzKid
  class TeamScore
    attr_reader :team, :player_scores

    def initialize team
      @team          = team
      @player_scores = []
    end

    def total
      player_scores.reduce(0) {|total_score, player| total_score + player[:score] }
    end

    def total_score_for player
      player_scores.select do |score|
        score[:player] == player
      end.reduce(0){|total, player| total + player[:score]}
    end

    def highest_scorer
      scoring_players = player_scores.map {|score| score[:player]}.uniq
      highest_scorer = scoring_players.max {|player| total_score_for player}
      {player: highest_scorer, total: total_score_for(highest_scorer)}
    end

    def award player, question, value
      @player_scores << {player: player, question: question, score: value}
    end
  end
end