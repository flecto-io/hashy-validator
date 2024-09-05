# frozen_string_literal: true

require "simplecov"
SimpleCov.start
require "minitest/autorun"
require_relative "../lib/hashy_validator"
require_relative "./database/sqlite"
require_relative "./model/samples"
require 'pry'

# I am using JSON.generate is because sqlite3 does not have the jsonb column type
class HashyArrayValidationTest < Minitest::Test
  # =================================
  # Success cases
  # =================================
  
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

  def test_ignore_empty_array_returns_success
    profile = Profile.new(name: "John Doe", notifications: JSON.generate([]))

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

  def test_valid_hashy_object_returns_success
    customer = Customer.new(age: 23, custom: JSON.generate({
      name: "John Doe",
      quantity: 20
    }))

    assert(customer.valid?)
  end


  def test_missing_optional_attribute_on_hashy_object_returns_success
    customer = Customer.new(age: 23, custom: JSON.generate({
      quantity: 20
    }))

    assert(customer.valid?)
  end

  def test_empty_hashy_object_returns_success
    customer = Customer.new(age: 23, custom: JSON.generate({}))

    assert(customer.valid?)
  end

  # =================================
  # Failures cases
  # =================================
  
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

  def test_invalid_hashy_object_returns_error
    customer = Customer.new(age: 23, custom: JSON.generate({
      name: "John Doe",
    }))

    refute(customer.valid?)
  end
end
