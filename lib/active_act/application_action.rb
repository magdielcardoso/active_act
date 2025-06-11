# frozen_string_literal: true

module ActiveAct
  class ApplicationAction
    class << self
      def before_call(method_name)
        @before_call_callbacks ||= []
        @before_call_callbacks << method_name
      end

      def after_call(method_name)
        @after_call_callbacks ||= []
        @after_call_callbacks << method_name
      end

      def on_error(method_name)
        @on_error_callbacks ||= []
        @on_error_callbacks << method_name
      end

      def _before_call_callbacks
        superclass.respond_to?(:_before_call_callbacks) ? (superclass._before_call_callbacks + (@before_call_callbacks || [])) : (@before_call_callbacks || [])
      end

      def _after_call_callbacks
        superclass.respond_to?(:_after_call_callbacks) ? (superclass._after_call_callbacks + (@after_call_callbacks || [])) : (@after_call_callbacks || [])
      end

      def _on_error_callbacks
        superclass.respond_to?(:_on_error_callbacks) ? (superclass._on_error_callbacks + (@on_error_callbacks || [])) : (@on_error_callbacks || [])
      end
    end

    def self.call(*args, **kwargs, &block)
      instance = new
      begin
        # Call all before_call callbacks
        _before_call_callbacks.each { |cb| instance.send(cb, *args, **kwargs) }
        instance.before_call(*args, **kwargs) if instance.respond_to?(:before_call)
        result = instance.call(*args, **kwargs, &block)
        # Call all after_call callbacks
        _after_call_callbacks.each { |cb| instance.send(cb, result) }
        instance.after_call(result) if instance.respond_to?(:after_call)
        if result.is_a?(ActiveAct::ActionResult)
          result
        else
          ActiveAct::ActionResult.new(result)
        end
      rescue StandardError => e
        # Call all on_error callbacks
        _on_error_callbacks.each { |cb| instance.send(cb, e) }
        instance.on_error(e) if instance.respond_to?(:on_error)
        ActiveAct::ActionResult.new(nil, error: e)
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
