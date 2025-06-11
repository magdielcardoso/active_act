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

      def act_as(type)
        @act_as_type = type
      end

      def retry_on(error_class, attempts: 3, wait: 0)
        @retry_on_config = { error_class: error_class, attempts: attempts, wait: wait }
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

      def _act_as_type
        @act_as_type || (superclass.respond_to?(:_act_as_type) ? superclass._act_as_type : nil)
      end

      def _retry_on_config
        @retry_on_config || (superclass.respond_to?(:_retry_on_config) ? superclass._retry_on_config : nil)
      end
    end

    def self.call(*args, as_job: true, **kwargs, &block)
      if _act_as_type == :job && as_job
        ActiveAct::ActionJob.perform_later(name, args, kwargs)
        ActiveAct::ActionResult.new({ enqueued: true, action: name, args: args, kwargs: kwargs })
      else
        instance = new
        retry_config = _retry_on_config
        attempts = retry_config ? retry_config[:attempts] : 1
        wait = retry_config ? retry_config[:wait] : 0
        error_class = retry_config ? retry_config[:error_class] : nil
        tries = 0
        begin
          tries += 1
          _before_call_callbacks.each { |cb| instance.send(cb, *args, **kwargs) }
          instance.before_call(*args, **kwargs) if instance.respond_to?(:before_call)
          result = instance.call(*args, **kwargs, &block)
          _after_call_callbacks.each { |cb| instance.send(cb, result) }
          instance.after_call(result) if instance.respond_to?(:after_call)
          if result.is_a?(ActiveAct::ActionResult)
            result
          else
            ActiveAct::ActionResult.new(result)
          end
        rescue StandardError => e
          if retry_config && e.is_a?(error_class) && tries < attempts
            sleep(wait) if wait.to_f > 0
            retry
          end
          _on_error_callbacks.each { |cb| instance.send(cb, e) }
          instance.on_error(e) if instance.respond_to?(:on_error)
          ActiveAct::ActionResult.new(nil, error: e)
        end
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
