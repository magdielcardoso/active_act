# frozen_string_literal: true

require "rails/generators"
require "rails/generators/migration"

module ActiveAct
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      desc "Creates the app/actions structure and the audit migration."

      def create_actions_directory
        empty_directory "app/actions"
      end

      def create_audit_migration
        migration_template "create_active_act_action_executions.rb", "db/migrate/#{migration_file_name}"
      end

      # Rails requires this for migration_template
      def self.next_migration_number(_dirname)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def migration_file_name
        "create_active_act_action_executions.rb"
      end
    end
  end
end
