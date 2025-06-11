# frozen_string_literal: true

module ActiveAct
  class Pipeline
    class << self
      def step(action_class)
        @steps ||= []
        @steps << action_class
      end

      def on_success(action_class)
        @on_success = action_class
      end

      def on_failure(action_class)
        @on_failure = action_class
      end

      def _steps
        superclass.respond_to?(:_steps) ? (superclass._steps + (@steps || [])) : (@steps || [])
      end

      def _on_success
        @on_success || (superclass.respond_to?(:_on_success) ? superclass._on_success : nil)
      end

      def _on_failure
        @on_failure || (superclass.respond_to?(:_on_failure) ? superclass._on_failure : nil)
      end

      def call(*args, **kwargs)
        result = nil
        _steps.each_with_index do |action, idx|
          result = idx.zero? ? action.call(*args, **kwargs) : action.call(result.value)
          break unless result.success?
        end
        if result&.success? && _on_success
          _on_success.call(result.value)
        elsif !result&.success? && _on_failure
          _on_failure.call(result&.error || result)
        else
          result
        end
      end
    end
  end
end
