class Score::ScoreController < ApplicationController

  def calculate_score

    game = Score::Game.new(params[:game].to_json)

    is_valid, message = game.is_valid?
    if is_valid == false
      render :status => :bad_request, :json => "game is not valid. error: #{message}".to_json
      return
    end

    total, best, worst = game.calculate_score
    score = Score::Score.new(total, best, worst)

    render :status => :ok, :json => score.to_json
  end
end
