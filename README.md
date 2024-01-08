<div style="display: flex">
  <a href="https://codeclimate.com/github/flecto-io/hashy-validator/maintainability"><img src="https://api.codeclimate.com/v1/badges/8818718c3f8ac08a1f05/maintainability" /></a>
  <a href="https://codeclimate.com/github/flecto-io/hashy-validator/test_coverage"><img src="https://api.codeclimate.com/v1/badges/8818718c3f8ac08a1f05/test_coverage" /></a>
</div>


# Summary

A implementation of hash_validator gem with ActiveModel::Validations.

# Install

<b>THIS GEM IS NOT READY FOR PRODUCTION YET!</b>

### Gemfile

```bash
gem 'hashy_validator', github: 'flecto-io/hashy-validator'
```

### RubyGems

<b>Not available yet!</b>

# Test

### Using Rake

```bash
rake test
```

### Testing single file 

```bash
ruby -I. test/validation_sqlite_test.rb
```

# Recommendations

- Use devcontainer to run the project in a container.

# References

https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html

https://github.com/jamesbrooks/hash_validator
