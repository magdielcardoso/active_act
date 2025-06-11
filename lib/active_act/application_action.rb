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

      # Auditing
      def auditable!
        @auditable = true
      end

      def _auditable?
        @auditable || (superclass.respond_to?(:_auditable?) ? superclass._auditable? : false)
      end

      # Authorization
      def require_user(role = nil)
        @required_user_role = role
      end

      def _required_user_role
        if defined?(@required_user_role)
          @required_user_role
        else
          (superclass.respond_to?(:_required_user_role) ? superclass._required_user_role : nil)
        end
      end

      # Param validation
      def param(name, type:, required: false)
        @params_schema ||= {}
        @params_schema[name] = { type: type, required: required }
      end

      def _params_schema
        superclass.respond_to?(:_params_schema) ? superclass._params_schema.merge(@params_schema || {}) : (@params_schema || {})
      end

      # Scheduling
      def schedule(every:)
        @schedule_config = { every: every }
        # Aqui poderíamos registrar para um scheduler externo, ex: Sidekiq::Cron, etc.
      end

      def _schedule_config
        @schedule_config || (superclass.respond_to?(:_schedule_config) ? superclass._schedule_config : nil)
      end
    end

    def self.call(*args, as_job: true, **kwargs, &block)
      # --- Auditing ---
      auditable = _auditable?
      start_time = Time.now if auditable
      audit_data = { action: name, args: args, kwargs: kwargs }
      begin
        # --- Param validation ---
        schema = _params_schema
        unless schema.empty?
          schema.each do |param, opts|
            value = begin
              kwargs[param] || args[schema.keys.index(param)]
            rescue StandardError
              nil
            end
            raise ArgumentError, "Missing required param: #{param}" if opts[:required] && value.nil?
            raise ArgumentError, "Param #{param} must be a #{opts[:type]}" if !value.nil? && !value.is_a?(opts[:type])
          end
        end
        # --- Authorization ---
        required_role = _required_user_role
        if required_role
          user = kwargs[:current_user] || args.find { |a| a.respond_to?(:role) }
          raise "Unauthorized: user required" unless user
          if required_role && !(user.respond_to?(:role) && user.role.to_sym == required_role.to_sym)
            raise "Unauthorized: must be #{required_role}"
          end
        end
        # --- Scheduling ---
        if _schedule_config && as_job
          # Enfileira como job agendado (simples, para demo; ideal: integração com cron/sidekiq)
          ActiveAct::ActionJob.set(wait: _schedule_config[:every]).perform_later(name, args, kwargs)
          return ActiveAct::ActionResult.new({ enqueued: true, scheduled: true, action: name, args: args,
                                               kwargs: kwargs })
        end
        # --- Job ---
        if _act_as_type == :job && as_job
          ActiveAct::ActionJob.perform_later(name, args, kwargs)
          return ActiveAct::ActionResult.new({ enqueued: true, action: name, args: args, kwargs: kwargs })
        end
        # --- Retry ---
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
          raise if auditable # para logar erro no audit abaixo

          ActiveAct::ActionResult.new(nil, error: e)
        end
      rescue StandardError => e
        audit_data[:error] = e
        raise
      ensure
        if auditable
          audit_data[:duration] = Time.now - start_time
          audit_data[:result] = if audit_data[:error]
                                  nil
                                else
                                  (defined?(result) ? result : nil)
                                end
          Rails.logger.info("[ActiveAct::Audit] #{audit_data.inspect}")
          # Persistência no banco
          ActiveAct::ActionExecution.create!(
            action: audit_data[:action],
            args: audit_data[:args].inspect,
            kwargs: audit_data[:kwargs].inspect,
            result: audit_data[:result].inspect,
            error: audit_data[:error]&.to_s,
            duration: audit_data[:duration],
            created_at: start_time
          )
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
