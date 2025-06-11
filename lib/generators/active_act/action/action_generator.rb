require "rails/generators/named_base"

module ActiveAct
  module Generators
    class ActionGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      desc "Creates a new action inheriting from ActiveAct::ApplicationAction."

      def create_action_file
        template "action.rb.tt", File.join("app/actions", class_path, "#{file_name}.rb")
      end
    end
  end
end
