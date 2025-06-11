# Authorization in ActiveAct

The `require_user` macro enforces that a user (and optionally a specific role) is present to execute the action.

---

## How to Use

Require any user:
```ruby
class MyAction < ActiveAct::ApplicationAction
  require_user
  def call(arg, current_user:)
    # ...
  end
end
```

Require a specific role:
```ruby
class AdminAction < ActiveAct::ApplicationAction
  require_user :admin
  def call(arg, current_user:)
    # ...
  end
end
```

---

## How it Works
- The macro checks for a `current_user` argument (keyword or positional with a `role` method).
- If a role is specified, it checks `current_user.role`.
- If the user is missing or the role does not match, an authorization error is raised.

---

## Tips
- Combine with `param` for full argument validation.
- You can use any symbol or string for the role (e.g., `:admin`, `"manager"`).
- For more complex policies, use custom logic in your action.

---

For more, see the main README and usage examples. 