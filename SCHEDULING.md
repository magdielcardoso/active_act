# Scheduling in ActiveAct

The `schedule` macro lets you run actions periodically using ActiveJob and your background job system.

---

## How to Use

Add `schedule every: ...` to your action:

```ruby
class CleanupOldRecords < ActiveAct::ApplicationAction
  schedule every: 1.day
  def call
    # ...
  end
end
```

---

## How it Works
- The macro registers the action to be enqueued at the specified interval.
- Uses ActiveJob's `set(wait: ...)` to schedule the job.
- Integrates with your job backend (Sidekiq, Async, etc).

---

## Tips
- Use for periodic tasks like cleanup, reporting, or syncing.
- For production, consider integrating with a cron scheduler or Sidekiq::Cron for robust scheduling.
- You can combine with other macros (auditable!, param, etc).

---

For more, see the main README and usage examples. 