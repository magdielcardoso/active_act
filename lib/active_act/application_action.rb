# frozen_string_literal: true

module ActiveAct
  class ApplicationAction
    def self.call(*args, **kwargs, &block)
      new(*args, **kwargs, &block).call
    end

    def call
      raise NotImplementedError, "You must implement the #call method in your action."
    end

    def fail(error = nil)
      raise(error || "Action failed")
    end
  end
end
