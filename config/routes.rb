ActiveAct::Engine.routes.draw do
  namespace :admin do
    resources :action_executions, only: %i[index show] do
      member do
        post :replay
      end
    end
  end
end 