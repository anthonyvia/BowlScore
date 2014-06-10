class Score::Game < Common::JsonModel

  attr_accessor :frames

  def initialize(json)
    self.from_json(json)

    new_frames = Array.new
    self.frames.each do |frame|
      new_frames.push(Score::Frame.new(frame.to_json))
    end

    self.frames = new_frames
  end

  # returns score, best case, and worst case scores
  def calculate_score
    total_score = 0

    frame_num = 0
    self.frames.each do |frame|
      next_frame = self.frames[frame_num + 1]
      frame_after_next = self.frames[frame_num + 2]

      frame_actual = frame.actual_total(next_frame, frame_after_next, frame_num + 1)
      total_score = total_score + frame_actual
      frame_num = frame_num + 1
    end

    best_case_score = total_score
    worst_case_score = total_score
    number_of_frames = self.frames.count

    if number_of_frames < MAX_FRAMES_COUNT
      perfect_frame = Score::Frame.new(PERFECT_FRAME_JSON)
      perfect_tenth_frame = Score::Frame.new(PERFECT_TENTH_FRAME_JSON)
      start_pos = number_of_frames - 2
      temp_frame_num = start_pos < 0 ? 0 : start_pos # TODO: what if self.frames is empty?
      current_frame = self.frames[temp_frame_num]
      next_frame = self.frames[temp_frame_num + 1]
      frame_after_next = perfect_frame
      best_case_score = best_case_score - current_frame.current_actual_total - (next_frame.nil? ? 0 : next_frame.current_actual_total)
      worst_case_score = worst_case_score - current_frame.current_actual_total - (next_frame.nil? ? 0 : next_frame.current_actual_total)

      until temp_frame_num == MAX_FRAMES_COUNT do
        next_frame = perfect_frame if next_frame.nil?
        is_ninth_frame = temp_frame_num == 8
        is_tenth_frame = temp_frame_num == 9

        if is_ninth_frame == true
          next_frame = perfect_tenth_frame
          frame_after_next = nil
        end
        if is_tenth_frame == true
          next_frame = nil
          frame_after_next = nil
        end

        frame_actual = current_frame.actual_total(next_frame, frame_after_next, temp_frame_num + 1)
        current_frame = next_frame
        best_case_score = best_case_score + frame_actual
        temp_frame_num = temp_frame_num + 1
      end

      worst_frame = Score::Frame.new(WORST_FRAME_JSON)
      start_pos = number_of_frames - 2
      temp_frame_num = start_pos < 0 ? 0 : start_pos # TODO: what if self.frames is empty?
      current_frame = self.frames[temp_frame_num]
      current_frame.reset_current_actual_total
      next_frame = self.frames[temp_frame_num + 1]
      frame_after_next = worst_frame

      until temp_frame_num == MAX_FRAMES_COUNT do
        next_frame = worst_frame if next_frame.nil?
        is_ninth_frame = temp_frame_num == 8
        is_tenth_frame = temp_frame_num == 9

        if is_ninth_frame == true
          next_frame = worst_frame
          frame_after_next = nil
        end
        if is_tenth_frame == true
          next_frame = nil
          frame_after_next = nil
        end

        frame_actual = current_frame.actual_total(next_frame, frame_after_next, temp_frame_num + 1)
        current_frame = next_frame
        worst_case_score = worst_case_score + frame_actual
        temp_frame_num = temp_frame_num + 1
      end
    end

    return total_score, best_case_score, worst_case_score
  end

  def is_valid?
    # TODO: check all are integers
    return false if self.frames.count > MAX_FRAMES_COUNT

    frame_num = 1
    self.frames.each do |frame|
      return false, "frame #{frame_num} has an invalid score" if frame.scores.any? { |score| score < 0 || score > 10 }

      frame_scores_sum = frame.raw_total
      if frame_num < 10
        return false, "frame #{frame_num} has an invalid number of scores" if frame.scores.count > MAX_SCORES_COUNT
        return false, "frame #{frame_num} has an invalid total score" if frame_scores_sum > MAX_FRAME_TOTAL_SCORE
      else
        return false, "frame #{frame_num} has an invalid number of scores" if frame.scores.count > MAX_TENTH_FRAME_SCORE_COUNT
        return false, "frame #{frame_num} has an invalid total score" if frame_scores_sum > MAX_TENTH_FRAME_TOTAL_SCORE

        if frame.scores.count == MAX_TENTH_FRAME_SCORE_COUNT
          return false, "tenth frame total score cannot exceed 30" if frame_scores_sum > MAX_TENTH_FRAME_TOTAL_SCORE

          first_two_scores_sum = frame.scores[0] + frame.scores[1]
          last_two_scores_sum = frame.scores[1] + frame.scores[2]
          return false, "tenth frame cannot have 3 scores if the first score is not 10 or if the first two scores do not total 10" if frame.scores[0] != 10 && first_two_scores_sum != 10
          return false, "last two scores of tenth frame cannot exceed ten if second score is not 10" if last_two_scores_sum > 10 && frame.scores[1] != 10
        end
      end

      frame_num = frame_num + 1
    end

    true
  end

  MAX_FRAMES_COUNT = 10
  MAX_FRAME_TOTAL_SCORE = 10
  MAX_SCORES_COUNT = 2
  MAX_TENTH_FRAME_SCORE_COUNT = 3
  MAX_TENTH_FRAME_TOTAL_SCORE = 30

  PERFECT_FRAME_JSON = "{\"scores\" : [10]}"
  PERFECT_TENTH_FRAME_JSON = "{\"scores\" : [10, 10, 10]}"
  WORST_FRAME_JSON = "{\"scores\" : [0, 0]}"

end
