ActiveAct::Engine.routes.draw do
  resources :action_executions, only: %i[index show] do
    member do
      post :replay
    end
  end
end
