# Pipelines in ActiveAct

ActiveAct Pipelines let you compose multiple actions into a robust, readable workflow. Each step is an action, and you can define handlers for success and failure.

---

## How to Use

Define a pipeline by inheriting from `ActiveAct::Pipeline`:

```ruby
class MyPipeline < ActiveAct::Pipeline
  step ValidateInput
  step ProcessOrder
  on_success NotifySuccess
  on_failure NotifyFailure
end

# Usage:
MyPipeline.call(order_params)
```

- Each `step` is an action; the result of each is passed to the next.
- If all steps succeed, `on_success` is called with the final result.
- If any step fails, `on_failure` is called with the error.

---

## Example

```ruby
class ValidateInput < ActiveAct::ApplicationAction
  def call(params)
    raise "Invalid!" unless params[:valid]
    params
  end
end

class ProcessOrder < ActiveAct::ApplicationAction
  def call(params)
    # ...
    { order_id: 123 }
  end
end

class NotifySuccess < ActiveAct::ApplicationAction
  def call(result)
    puts "Order processed: #{result[:order_id]}"
  end
end

class NotifyFailure < ActiveAct::ApplicationAction
  def call(error)
    puts "Pipeline failed: #{error}"
  end
end

class OrderPipeline < ActiveAct::Pipeline
  step ValidateInput
  step ProcessOrder
  on_success NotifySuccess
  on_failure NotifyFailure
end

OrderPipeline.call(valid: true)
OrderPipeline.call(valid: false)
```

---

## Tips
- Pipelines make it easy to build complex business flows.
- You can use any action as a step or handler.
- Handlers are optional; if not defined, the pipeline returns the last result.

---

For more, see the main README and usage examples. 