# Parameter Validation in ActiveAct

The `param` macro lets you declare and validate required and typed parameters for your actions.

---

## How to Use

Declare parameters:
```ruby
class MyAction < ActiveAct::ApplicationAction
  param :user_id, type: Integer, required: true
  param :email, type: String, required: false

  def call(user_id:, email: nil)
    # ...
  end
end
```

---

## How it Works
- Each `param` macro adds a parameter to the schema.
- On `.call`, the gem checks for presence and type.
- If a required param is missing or the type is wrong, an ArgumentError is raised.

---

## Tips
- Use with keyword arguments for best DX.
- Combine with `require_user` for secure actions.
- You can use any Ruby class for `type` (e.g., `String`, `Integer`, `Post`).

---

For more, see the main README and usage examples. 