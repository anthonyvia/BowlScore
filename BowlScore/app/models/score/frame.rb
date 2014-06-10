class Score::Frame < Common::JsonModel

  attr_accessor :scores
  attr_reader :is_strike, :is_spare, :ball1, :ball2, :current_actual_total

  def initialize(json)
    self.from_json(json)

    @ball1 = !scores.nil? && scores.count > 0 ? scores[0] : 0
    @ball2 = !scores.nil? && scores.count > 1 ? scores[1] : 0

    @is_strike = false
    @is_spare = false
    if @ball1 == 10
      @is_strike = true
    elsif self.raw_total == 10
      @is_spare = true
    end

    @current_actual_total = raw_total
  end

  def raw_total
    scores.inject(:+)
  end

  def actual_total(next_frame, frame_after_next, frame_number)
    actual_total = raw_total
    next_ball_score = 0
    ball_after_next_score = 0

    if next_frame.nil? && !frame_after_next.nil?
      raise StandardError, "next_frame must be set if frame_after_next is set"
    end

    if !next_frame.nil?
      next_ball_score = next_frame.ball1
      ball_after_next_score = next_frame.ball2

      if next_frame.is_strike == true && frame_number != 9
        ball_after_next_score = frame_after_next.nil? ? 0 : frame_after_next.ball1
      end
    end

    if self.is_strike == true
      actual_total = raw_total + next_ball_score + ball_after_next_score
    end

    if self.is_spare == true
      actual_total = raw_total + next_ball_score
    end

    @current_actual_total = actual_total
    actual_total
  end

  def reset_current_actual_total
    @current_actual_total = raw_total
  end
end
