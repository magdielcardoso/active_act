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

Run the install generator to set up the base structure:

```sh
$ rails generate active_act:install
```

This will create the `app/actions` directory and a base `application_action.rb` file.

## Usage

### Creating a new Action

You can manually create a new action by inheriting from `ApplicationAction`:

```ruby
# app/actions/send_welcome_email.rb
class SendWelcomeEmail < ApplicationAction
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

Or, use the (upcoming) generator:

```sh
$ rails generate active_act:action SendWelcomeEmail
```

### Executing an Action

You can call your action from anywhere in your app:

```ruby
SendWelcomeEmail.call(user)
```

## Base Action API

The generated `ApplicationAction` provides:

- `.call(*args, **kwargs, &block)`: Instantiates and runs the action.
- `#call`: To be implemented in your subclass.
- `#fail(error = nil)`: Raises an error to signal failure.

## Example

```ruby
# app/actions/process_payment.rb
class ProcessPayment < ApplicationAction
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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/magdielcardoso/active_act.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
