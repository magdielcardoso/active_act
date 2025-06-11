# frozen_string_literal: true

module ActiveAct
  class ApplicationAction
    def self.call(*args, **kwargs, &block)
      instance = new
      result = instance.call(*args, **kwargs, &block)
      if result.is_a?(ActiveAct::ActionResult)
        result
      else
        ActiveAct::ActionResult.new(result)
      end
    end

    def call(*args, **kwargs)
      raise NotImplementedError, "You must implement the #call method in your action."
    end

    def fail(error = nil)
      raise(error || "Action failed")
    end
  end
end
