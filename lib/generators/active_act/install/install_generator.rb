# frozen_string_literal: true

require "rails/generators"

module ActiveAct
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates the app/actions structure."

      def create_actions_directory
        empty_directory "app/actions"
      end
    end
  end
end
