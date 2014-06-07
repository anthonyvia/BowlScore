BowlScore::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  namespace :score do
    post 'calculate_score', to: 'score#calculate_score'
  end
end
