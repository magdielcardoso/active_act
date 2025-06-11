# frozen_string_literal: true

module ActiveAct
  class ActionResult
    attr_reader :value, :error

    def initialize(value, error: nil)
      @value = value
      @error = error
    end

    def success?
      @error.nil?
    end

    def then(next_action)
      return self unless success?

      result = next_action.call(@value)
      result.is_a?(ActionResult) ? result : ActionResult.new(result)
    rescue StandardError => e
      ActionResult.new(nil, error: e)
    end
  end
end
