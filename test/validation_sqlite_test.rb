# frozen_string_literal: true

require "simplecov"
SimpleCov.start
require "minitest/autorun"
require_relative "../lib/hashy_validator"

# Create database
conn = { adapter: "sqlite3", database: ":memory:" }
ActiveRecord::Base.establish_connection(conn)

# Schema
ActiveRecord::Schema.define do
  create_table :profiles do |t|
    t.string(:name)
    t.string(:notifications)

    # @Todo: use Postgres
    # Also check if i really need to create test with pg integration
    # t.jsonb :notifications
  end
  create_table :products do |t|
    t.string(:name)
    t.string(:discount_by_quantity)
  end

  create_table :items do |t|
    t.string(:name)
    t.string(:metas)
  end
end

# Model
class Profile < ActiveRecord::Base
  validates :name, presence: true
  validates :notifications, hashy_array: {
    type: HashValidator.multiple("string", "unique"),
    header: HashValidator::Validations::Optional.new("string"),
  }
end

class Product < ActiveRecord::Base
  validates :name, presence: true
  validates :discount_by_quantity, hashy_array: {
    uuid: "unique",
    quantity: HashValidator.multiple("numeric"),
    price: HashValidator.multiple("numeric"),
    active: HashValidator.multiple("boolean"),
  }
end

class Item < ActiveRecord::Base
  validates :name, presence: true
  validates :metas,
    hashy_array: {
      active: HashValidator.multiple("boolean"),
    },
    if: ->(item) { self.quantity > 1 }

  attribute :quantity, :integer
end

# I am using JSON.generate is because sqlite3 does not have the jsonb column type
class HashyArrayValidationTest < Minitest::Test
  def test_valid_hashy_returns_success
    profile = Profile.new(name: "John Doe", notifications: JSON.generate(
      [
        {
          type: "something",
          header: "something header"
        },
      ],
    ))

    assert(profile.valid?)
  end

  def test_valid_numeric_hashy_returns_success
    product = Product.new(name: "IPhone", discount_by_quantity: JSON.generate(
      [
        {
          uuid: "1a2b3c4d5e6f7g8h9i0j",
          quantity: 3,
          price: 100,
          active: true,
        },
      ],
    ))

    assert(product.valid?)
  end

  def test_valid_hashy_with_condition_returns_success
    item = Item.new(name: "Go Pro", quantity: 1, metas: JSON.generate([{}]))

    assert(item.valid?)
  end

  def test_valid_hashy_with_condition_returns_fail
    item = Item.new(name: "Go Pro", quantity: 2, metas: JSON.generate([{}]))

    refute(item.valid?)
  end

  def test_invalid_numeric_hashy_returns_error
    product = Product.new(name: "IPhone", discount_by_quantity: JSON.generate(
      [
        {
          uuid: "1a2b3c4d5e6f7g8h9i0j",
          quantity: "something",
          price: 10,
          active: false,
        },
        {
          uuid: "1a2b3c4d5e6f7g8h9i0j",
          quantity: "something 2",
          price: 10,
          active: false,
        },
      ],
    ))

    refute(product.valid?)
  end

  def test_invalid_hash_and_returns_error
    product = Product.new(name: "IPhone", discount_by_quantity: "abacate")

    refute(product.valid?)
  end

  def test_invalid_not_unique_hashy_returns_error
    profile = Profile.new(name: "John Doe", notifications: JSON.generate(
      [
        {
          type: "something",
        },
        {
          type: "something",
        },
      ],
    ))

    refute(profile.valid?)
  end

  def test_invalid_not_array_hashy_returns_error
    profile = Profile.new(name: "John Doe", notifications: JSON.generate(
      { type: "something" },
    ))

    refute(profile.valid?)
  end

  def test_invalid_wrong_type_hashy_returns_error
    profile = Profile.new(name: "John Doe", notifications: JSON.generate(
      [
        {
          type: 1,
        },
      ],
    ))

    refute(profile.valid?)
  end

  def test_invalid_hashy_returns_error
    profile = Profile.new(name: "John Doe", notifications: [
      {
        test: "something",
      },
    ])

    refute(profile.valid?)
  end
end
