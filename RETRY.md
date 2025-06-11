# Retry Logic in ActiveAct Actions

ActiveAct allows you to automatically retry actions on specific errors using the Rails-like macro `retry_on`.

---

## How to Use

Add the macro to your action:

```ruby
class FetchData < ActiveAct::ApplicationAction
  retry_on NetworkError, attempts: 3, wait: 2.seconds

  def call(url)
    # Logic that might fail
  end
end
```

- `NetworkError` is the exception to retry on.
- `attempts` is the maximum number of tries (default: 3).
- `wait` is the time to wait between attempts (default: 0).

---

## Example

```ruby
class UnstableAction < ActiveAct::ApplicationAction
  retry_on RuntimeError, attempts: 5, wait: 1

  def call
    raise "Random failure" if rand < 0.7
    "Success!"
  end
end

result = UnstableAction.call
if result.success?
  puts result.value
else
  puts "Failed after retries: #{result.error}"
end
```

---

## Tips
- Only the specified error class triggers a retry.
- All other errors are handled normally.
- You can use any exception class.
- Retries are handled automatically in the `.call` method.

---

For more, see the main README and usage examples. 