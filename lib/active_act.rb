# frozen_string_literal: true

require_relative "active_act/version"
require_relative "active_act/action_result"
require_relative "active_act/application_action"
require_relative "active_act/action_job"

require "active_act/engine"

module ActiveAct
  class Error < StandardError; end
end
