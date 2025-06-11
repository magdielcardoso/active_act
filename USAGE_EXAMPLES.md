# ActiveAct Usage Examples

This document provides practical examples of how to use the ActiveAct gem in your Rails application.

---

## 1. Basic Action with Arguments

```ruby
class CalculateTotal < ActiveAct::ApplicationAction
  def call(order, discount: 0)
    total = order.items.sum(&:price) - discount
    { total: total }
  end
end

order = Order.find(1)
result = CalculateTotal.call(order, discount: 10)

if result.success?
  puts "Total: #{result.value[:total]}"
else
  puts "Error: #{result.error}"
end
```

---

## 2. Chaining Actions with `.then`

```ruby
class CreateInvoice < ActiveAct::ApplicationAction
  def call(total:)
    invoice = Invoice.create!(amount: total)
    { invoice: invoice }
  end
end

result = CalculateTotal.call(order, discount: 10)
               .then(CreateInvoice)

if result.success?
  puts "Invoice created: #{result.value[:invoice].id}"
else
  puts "Error: #{result.error}"
end
```

---

## 3. Multiple Chaining

```ruby
class SendInvoiceEmail < ActiveAct::ApplicationAction
  def call(invoice:)
    InvoiceMailer.send_invoice(invoice).deliver_later
    { emailed: true }
  end
end

result = CalculateTotal.call(order, discount: 10)
               .then(CreateInvoice)
               .then(SendInvoiceEmail)

if result.success?
  puts "Invoice emailed!"
else
  puts "Error: #{result.error}"
end
```

---

## 4. Handling Errors in Actions

```ruby
class RiskyAction < ActiveAct::ApplicationAction
  def call(data)
    raise "Something went wrong!" if data.nil?
    { ok: true }
  rescue => e
    fail(e)
  end
end

result = RiskyAction.call(nil)

if result.success?
  puts "Success!"
else
  puts "Error: #{result.error.message}"
end
```

---

## 5. Using *args and **kwargs for Flexibility

```ruby
class FlexibleAction < ActiveAct::ApplicationAction
  def call(*args, **kwargs)
    { args: args, kwargs: kwargs }
  end
end

result = FlexibleAction.call(1, 2, foo: "bar", baz: 42)
puts result.value # => { args: [1, 2], kwargs: { foo: "bar", baz: 42 } }
```

---

## 6. Custom Return Types

```ruby
class ReturnObject < ActiveAct::ApplicationAction
  def call(name)
    OpenStruct.new(greeting: "Hello, #{name}!")
  end
end

result = ReturnObject.call("Alice")
puts result.value.greeting # => "Hello, Alice!"
```

---

## 7. Chaining with Custom Objects

```ruby
class AddGreeting < ActiveAct::ApplicationAction
  def call(person)
    person.greeting = "Hi, #{person.name}!"
    person
  end
end

person = OpenStruct.new(name: "Bob")
result = ReturnObject.call(person.name).then(AddGreeting)
puts result.value.greeting # => "Hi, Bob!"
```

---

## 8. Checking for Success and Error

```ruby
result = SomeAction.call(...)

if result.success?
  puts "It worked!"
else
  puts "Something failed: #{result.error}"
end
```

---

## 9. Chaining with Early Failure

If any action in the chain fails, the chain stops and the error is propagated:

```ruby
result = ActionA.call(...)
           .then(ActionB) # If ActionA fails, ActionB is not called
           .then(ActionC)

unless result.success?
  puts "Chain failed: #{result.error}"
end
```

---

## 10. Using with Keyword Arguments Only

```ruby
class KeywordOnly < ActiveAct::ApplicationAction
  def call(foo:, bar:)
    foo + bar
  end
end

result = KeywordOnly.call(foo: 2, bar: 3)
puts result.value # => 5
```

---

## 11. Using Callbacks (before_call, after_call, on_error)

You can add callbacks to your actions using Rails-like macros. This allows you to run code before, after, or on error during the action execution.

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

# Usage:
post = Post.new(id: 1, title: "hello world")
result = UpcasePostTitle.call(post)
# Output:
# About to upcase the title for post: 1 (hello world)
# Finished upcasing. New title: HELLO WORLD

# If an error occurs in call, notify_error will be called with the exception.
```

---

## 12. Running Actions as Jobs

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

# Usage:
post = Post.create!(title: "hello world")
result = UpcasePostTitle.call(post)
# => Enqueues the job and returns an ActionResult with { enqueued: true, ... }
```

- If you do **not** declare `act_as :job`, the action runs synchronously as usual.
- Internally, a parameter `as_job: true/false` is used to prevent infinite job loops.
- You can use callbacks and chaining with job actions as well.

**Use cases:**
- Email delivery, notifications, integrations, or any background task.

--- 