# frozen_string_literal: true

module ActiveAct
  class Engine < ::Rails::Engine
    isolate_namespace ActiveAct

    initializer "active_act.assets" do |app|
      # Para Sprockets (funciona automaticamente, mas pode ser explicitado)
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:paths)
        app.config.assets.paths << root.join("app/assets/images")
      end

      # Para Propshaft (só adiciona se estiver presente)
      if app.config.respond_to?(:propshaft) && app.config.propshaft.respond_to?(:paths)
        app.config.propshaft.paths << root.join("app/assets/images")
      end
    end
  end
end
