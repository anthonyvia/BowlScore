class Score::Score

  attr_accessor :total, :best_case, :worst_case

  def initialize(total, best_case, worst_case)
    @total = total
    @best_case = best_case
    @worst_case = worst_case
  end

end
