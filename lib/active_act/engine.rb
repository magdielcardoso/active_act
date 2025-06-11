# frozen_string_literal: true

module ActiveAct
  class Engine < ::Rails::Engine
    isolate_namespace ActiveAct

    initializer "active_act.autoload", before: :set_autoload_paths do |app|
      app.config.paths.add "app/actions", eager_load: true
      # Adiciona paths para controllers e views administrativos da engine
      config.paths.add "lib/active_act/controllers", eager_load: true
      config.paths.add "lib/active_act/views"
      config.autoload_paths << root.join("lib/active_act/controllers")
      config.autoload_paths << root.join("lib/active_act/views")
    end

    routes.draw do
      namespace :admin do
        resources :action_executions, only: %i[index show] do
          member do
            post :replay
          end
        end
      end
    end
  end
end
