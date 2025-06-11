<p align="center">
  <img src=".github/images/icon.svg" alt="ActiveAct Logo" width="350"/>
</p>

<p align="center">
  <a href="https://badge.fury.io/rb/active_act"><img src="https://badge.fury.io/rb/active_act.svg" alt="Gem Version"/></a>
  <a href="https://github.com/magdielcardoso/active_act/actions/workflows/main.yml"><img src="https://github.com/magdielcardoso/active_act/actions/workflows/main.yml/badge.svg" alt="Build Status"/></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/></a>
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
