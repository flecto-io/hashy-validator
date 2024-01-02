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
        # Also check if i really need to create test with pg integration
        # t.jsonb :notifications
    end
end

# Model
class Profile < ActiveRecord::Base
    validates :name, presence: true
    validates :notifications, hashy_array: {
        type: HashValidator.multiple('required', 'string', 'unique'),
    }
end

# I am using JSON.generate is because sqlite3 does not have the jsonb column type
class HashyArrayValidationTest < Minitest::Test
    def test_valid_hashy_returns_error
        profile = Profile.new(name: 'John Doe', notifications: JSON.generate(
          [
               {
                 type: 'something'
               }
            ]
        ))

        assert profile.valid?
    end
    def test_invalid_not_unique_hashy_returns_error
        profile = Profile.new(name: 'John Doe', notifications: JSON.generate(
          [
                {
                  type: 'something'
                },
                {
                  type: 'something'
                },
            ]
        ))

        refute profile.valid?
    end
    def test_invalid_wrong_type_hashy_returns_error
        profile = Profile.new(name: 'John Doe', notifications: JSON.generate(
          [
            {
              type: 1
            },
          ]
        ))

        refute profile.valid?
    end
    def test_invalid_hashy_returns_error
        profile = Profile.new(name: 'John Doe', notifications: [
          {
            test: 'something'
          }
        ])

        refute profile.valid?
    end
end
