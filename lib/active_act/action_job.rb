# frozen_string_literal: true

module ActiveAct
  class ActionJob < ActiveJob::Base
    queue_as :default

    def perform(action_class_name, args, kwargs)
      action_class = action_class_name.constantize
      action_class.call(*args, **kwargs, as_job: false)
    end
  end
end
