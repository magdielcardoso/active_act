# Running Actions as Jobs with ActiveAct

ActiveAct allows you to turn any action into an asynchronous job using Rails' ActiveJob, simply by declaring a macro in your action class.

---

## How to Enable Job Mode

Add the macro at the top of your action:

```ruby
class MyAction < ActiveAct::ApplicationAction
  act_as :job

  def call(arg1, arg2)
    # your logic here
  end
end
```

Now, when you call `MyAction.call(...)`, the action will be enqueued as a job and executed asynchronously.

---

## Example

```ruby
class UpcasePostTitle < ActiveAct::ApplicationAction
  act_as :job

  def call(post)
    post.title = post.title.upcase
    post.save!
    post
  end
end

post = Post.create!(title: "hello world")
result = UpcasePostTitle.call(post)
# => Enqueues the job and returns an ActionResult with { enqueued: true, ... }
```

---

## How it Works

- The macro `act_as :job` tells ActiveAct to use ActiveJob for this action.
- When you call `.call`, the action is enqueued as a job.
- Internally, a parameter `as_job: true/false` is used to prevent infinite job loops (the job itself runs the action synchronously).
- If you do **not** declare `act_as :job`, the action runs synchronously as usual.

---

## Using with Callbacks and Chaining

You can use all callbacks (`before_call`, `after_call`, `on_error`) and chaining (`.then`) with job actions as well.

---

## Use Cases

- Email delivery
- Notifications
- Integrations with external services
- Any long-running or background task

---

## Tips

- The return value of `.call` when enqueued is an `ActionResult` with `{ enqueued: true, ... }`.
- You can pass any arguments to `.call` as usual.
- Jobs are enqueued to the default queue, but you can customize this by overriding `queue_as` in your action or job.

---

## Troubleshooting

- **Infinite job loop?** This is prevented by the `as_job` parameter. If you override `.call`, make sure to pass `as_job: false` when running inside a job.
- **Need to run synchronously?** Just don't declare `act_as :job`.

---

For more, see the main README and usage examples. 