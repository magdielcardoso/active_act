# Auditing in ActiveAct

The `auditable!` macro enables automatic logging of action executions, arguments, results, errors, and duration.

---

## How to Use

Add `auditable!` to your action:

```ruby
class MyAction < ActiveAct::ApplicationAction
  auditable!
  def call(arg)
    # ...
  end
end
```

---

## What is Logged?
- Action name
- Arguments and keyword arguments
- Result (if successful)
- Error (if any)
- Duration (in seconds)

All logs are sent to `Rails.logger` by default:

```
[ActiveAct::Audit] {action: "MyAction", args: [...], kwargs: {...}, result: ..., error: nil, duration: 0.002}
```

---

## Tips
- You can combine `auditable!` with other macros (retry, param, require_user, etc).
- For custom logging destinations, override the logger or monkey-patch the audit logic.

---

For more, see the main README and usage examples. 