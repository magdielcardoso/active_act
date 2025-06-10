# frozen_string_literal: true

require "rails/generators"

module ActiveAct
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates the app/actions structure and the base application_action.rb file."

      def create_actions_directory
        empty_directory "app/actions"
      end

      def copy_application_action
        template "application_action.rb", "app/actions/application_action.rb"
      end
    end
  end
end
