require 'active_record'
require 'minitest/autorun'
require_relative '../lib/hashy_validator'

# Create database
conn = { adapter: "sqlite3", database: ":memory:" }
ActiveRecord::Base.establish_connection(conn)

# Schema
ActiveRecord::Schema.define do
    create_table :profiles do |t|
        t.string :name
        t.string :notifications
        
        # @Todo: use Postgres
        # t.jsonb :notifications
    end
end

class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
        record.errors.add attribute, (options[:message] || "is not an email") unless
          /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.match?(value)
    end
end

# Model
class Profile < ActiveRecord::Base
    validates :name, presence: true
    validates :notifications, hashy_array: {
        type: HashValidator.multiple('required', 'string', 'unique', lambda { |v| v > 0 }),
    }
end

class HashyArrayValidationTest < Minitest::Test
    # not working
    # def test_valid_hashy_returns_error
    #     profile = Profile.new(name: 'John Doe', notifications: [
    #       {
    #         type: 'something'
    #       }
    #     ])
    #
    #     assert profile.valid?
    # end
    def test_invalid_hashy_returns_error
        profile = Profile.new(name: 'John Doe', notifications: [
          {
            test: 'something'
          }
        ])

        refute profile.valid?
    end
end
