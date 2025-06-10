module ActiveAct
  class Engine < ::Rails::Engine
    isolate_namespace ActiveAct

    initializer 'active_act.autoload', before: :set_autoload_paths do |app|
      app.config.paths.add 'app/actions', eager_load: true
    end
  end
end