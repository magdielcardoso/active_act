# frozen_string_literal: true

# Base class for all domain actions
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
