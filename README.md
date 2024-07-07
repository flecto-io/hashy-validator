<div style="display: flex">
  <a href="https://codeclimate.com/github/flecto-io/hashy-validator/maintainability"><img src="https://api.codeclimate.com/v1/badges/8818718c3f8ac08a1f05/maintainability" /></a>
  <a href="https://codeclimate.com/github/flecto-io/hashy-validator/test_coverage"><img src="https://api.codeclimate.com/v1/badges/8818718c3f8ac08a1f05/test_coverage" /></a>
</div>

# HashyValidator

HashyValidator is a custom Ruby on Rails validator designed to validate an array of hashes based on [HashValidator](https://github.com/jamesbrooks/hash_validator) criteria but also the following new criteria:
- `unique`: A value within each hash that has to be unique across the whole array

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hashy_validator'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install hashy_validator
```

## Usage

To leverage HashyValidator in your Rails model, follow these steps:

1. Add the gem to your Gemfile and run `bundle install` as mentioned above.

2. In your model, use the `validate` method to apply the `hashy_array` validation.

   ```ruby
   class YourModel < ApplicationRecord
     validates :pricing, hashy_array: {
       minutes: HashValidator.multiple('integer', 'unique'),
       price_cents: HashValidator.multiple('integer')
     }
   end
   ```
   
   Customize each entry validators according to [HashValidator](https://github.com/jamesbrooks/hash_validator) criteria

# Testing

```bash
rake test
```

## Contributing

Bug reports and pull requests are welcome. This project is intended to be a safe, welcoming space for collaboration. To ease up contribution we provide a VSCode _devcontainer_ to run the project in a container.
Before submitting a PR do not forget to run all tests by doing `rake test` or against a single file `ruby -I. test/validation_sqlite_test.rb`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
