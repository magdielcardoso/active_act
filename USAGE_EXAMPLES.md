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