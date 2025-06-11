<p align="center">
  <img src=".github/images/icon.svg" alt="ActiveAct Logo" width="350"/>
</p>

<p align="center">
  <a href="https://badge.fury.io/rb/active_act"><img src="https://badge.fury.io/rb/active_act.svg" alt="Gem Version"/></a>
  <a href="https://github.com/magdielcardoso/active_act/actions/workflows/main.yml"><img src="https://github.com/magdielcardoso/active_act/actions/workflows/main.yml/badge.svg" alt="Build Status"/></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/></a>
</p>

<p align="center">
  <b>
    <a href="RETRY.md">Retry</a> |
    <a href="PIPELINE.md">Pipeline</a> |
    <a href="USAGE_EXAMPLES.md">Usage Examples</a> |
    <a href="ACTION_JOBS.md">Action Jobs</a>
  </b>
</p>

# ActiveAct

ActiveAct is a Rails Engine that introduces a standardized Action layer for your Rails applications. It provides a base class and generators to help you organize business logic in a clean, reusable way.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_act'
```

And then execute:

```sh
$ bundle install
```

Run the install generator to set up the actions directory:

```sh
$ rails generate active_act:install
```

This will create the `app/actions` directory. The base class `ActiveAct::ApplicationAction` is provided by the gem and does not need to be generated in your app.

## Usage

### Creating a new Action

Create a new action by inheriting from `ActiveAct::ApplicationAction`:

```ruby
# app/actions/send_welcome_email.rb
class SendWelcomeEmail < ActiveAct::ApplicationAction
  def initialize(user)
    @user = user
  end

  def call
    # Your business logic here
    UserMailer.welcome(@user).deliver_later
  rescue => e
    fail(e)
  end
end
```

### Executing an Action

You can call your action from anywhere in your app:

```ruby
SendWelcomeEmail.call(user)
```

### Generating an Action with the Generator

You can use the built-in generator to quickly scaffold a new action:

```sh
rails generate active_act:action ActionName
```

**Example:**

```sh
rails generate active_act:action SendWelcomeEmail
```

This will create the file `app/actions/send_welcome_email.rb` with the following content:

```ruby
class SendWelcomeEmail < ActiveAct::ApplicationAction
  # Uncomment and customize the initializer if needed
  # def initialize(args)
  #   @args = args
  # end

  def call
    # Implement your business logic here
    raise NotImplementedError, "You must implement the #call method in SendWelcomeEmail"
  end
end
```

## Base Action API

The provided `ActiveAct::ApplicationAction` includes:

- `.call(*args, **kwargs, &block)`: Instantiates and runs the action.
- `#call`: To be implemented in your subclass.
- `#fail(error = nil)`: Raises an error to signal failure.

## Flexible Arguments and Chaining Actions

### Passing Arguments to Actions

You can define your action's `call` method to accept any arguments you need (positional or keyword). For maximum flexibility, use `*args, **kwargs`:

```ruby
class OrderProcess < ActiveAct::ApplicationAction
  def call(order, user:)
    # business logic here
    { order: order, user: user }
  end
end

OrderProcess.call(order, user: user)
```

### ActionResult: Handling Results

Every call to an action returns an `ActionResult` object, which provides:

- `.value` → the value returned by your action (usually a hash or object)
- `.error` → nil if successful, or the exception if an error occurred
- `.success?` → true if no error

Example:

```ruby
result = OrderProcess.call(order, user: user)
if result.success?
  puts result.value # => { order: ..., user: ... }
else
  puts "Error: #{result.error}"
end
```

### Chaining Actions with `.then`

You can chain actions so that the result of one is passed as the argument to the next:

```ruby
class NotifyUser < ActiveAct::ApplicationAction
  def call(result)
    user = result[:user]
    # notify user logic
    { notified: true }
  end
end

result = OrderProcess.call(order, user: user).then(NotifyUser)
if result.success?
  puts "User notified!"
else
  puts "Error: #{result.error}"
end
```

- The value returned by the first action is passed as the first argument to the next action's `call` method.
- You can chain as many actions as you want: `ActionA.call(...).then(ActionB).then(ActionC)`

## Callbacks for Actions

You can add callbacks to your actions using Rails-like macros:

- `before_call :method_name` — runs before the main `call` method
- `after_call :method_name` — runs after a successful `call`, receives the result
- `on_error :method_name` — runs if any error occurs, receives the exception

You can register multiple callbacks for each type. The methods can be private or public.

**Example:**

```ruby
class UpcasePostTitle < ActiveAct::ApplicationAction
  before_call :log_start
  after_call  :log_finish
  on_error    :notify_error

  def call(post)
    post.title = post.title.upcase
    post
  end

  private

  def log_start(post)
    puts "About to upcase the title for post: #{post.id} (#{post.title})"
  end

  def log_finish(result)
    puts "Finished upcasing. New title: #{result.title}"
  end

  def notify_error(error)
    puts "Error while upcasing post title: #{error.message}"
  end
end
```

- All callbacks are optional.
- You can still use instance methods named `before_call`, `after_call`, or `on_error` for compatibility.
- Callbacks are executed in the order they are declared.

## Example

```ruby
# app/actions/process_payment.rb
class ProcessPayment < ActiveAct::ApplicationAction
  def initialize(order)
    @order = order
  end

  def call
    PaymentService.charge(@order)
  rescue PaymentService::Error => e
    fail(e)
  end
end

# Usage:
ProcessPayment.call(order)
```

## Running Actions as Jobs

You can make any action run asynchronously as an ActiveJob by adding the macro:

```ruby
class UpcasePostTitle < ActiveAct::ApplicationAction
  act_as :job

  def call(post)
    post.title = post.title.upcase
    post.save!
    post
  end
end
```

- When you call `UpcasePostTitle.call(post)`, the action is enqueued as a job and will run asynchronously.
- The return value is an `ActionResult` with `{ enqueued: true, action: ..., args: ..., kwargs: ... }`.
- If you do **not** declare `act_as :job`, the action runs synchronously as usual.

**How it works:**
- The macro `act_as :job` tells ActiveAct to use ActiveJob for this action.
- Internally, a parameter `as_job: true/false` is used to prevent infinite job loops.
- You can still use all callbacks and chaining features with job actions.

**Use cases:**
- Email delivery, notifications, integrations, or any long-running/background task.

**Example:**
```ruby
UpcasePostTitle.call(post) # Enqueues the job
```

## Composing Actions with Pipelines

You can compose multiple actions into a pipeline for complex workflows. Each step is an action, and you can define handlers for success and failure:

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

Pipelines make it easy to build robust, readable business flows.

## Advanced Macros

ActiveAct provides powerful macros to make your actions safer, more maintainable, and Rails-like:

- **auditable!** — Logs execution, arguments, result, error, and duration automatically.
- **require_user [:role]** — Requires a user (and optionally a specific role) to execute the action.
- **param :name, type:, required:** — Declares and validates required and typed parameters.
- **schedule every: ...** — Schedules the action to run periodically via ActiveJob.

See the dedicated docs for details:

- [Auditing](AUDITING.md)
- [Authorization](AUTHORIZATION.md)
- [Parameter Validation](PARAMS.md)
- [Scheduling](SCHEDULING.md)

**Example:**
```ruby
class UpcasePostTitle < ActiveAct::ApplicationAction
  auditable!
  param :post, type: Post, required: true
  require_user :admin
  schedule every: 1.day

  before_call :log_start
  after_call  :log_finish
  on_error    :notify_error

  def call(post, current_user:)
    post.title = post.title.upcase
    post.save!
    post
  end

  private

  def log_start(post, current_user:)
    puts "About to upcase the title for post: #{post.id} (#{post.title}), by user: #{current_user.id}"
  end

  def log_finish(result)
    puts "Finished upcasing. New title: #{result.title}"
  end

  def notify_error(error)
    puts "Error while upcasing post title: #{error.message}"
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/magdielcardoso/active_act.

## How to contribute

1. Fork the repository: https://github.com/magdielcardoso/active_act
2. Create a new branch for your feature or fix:
   ```sh
   git checkout -b my-feature
   ```
3. Make your changes, including tests if applicable.
4. Run the test suite to ensure everything is working:
   ```sh
   bundle install
   bundle exec rake spec
   ```
5. Commit your changes and push your branch:
   ```sh
   git add .
   git commit -m "Describe your change"
   git push origin my-feature
   ```
6. Open a Pull Request on GitHub and describe your contribution.

Thank you for helping to improve ActiveAct!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
