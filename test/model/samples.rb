# frozen_string_literal: true

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
    if: ->(_item) { quantity > 1 }

  attribute :quantity, :integer
end

class Customer < ActiveRecord::Base
  validates :age, presence: true, numericality: { only_integer: true, greater_than: 20, less_than: 100 }
  validates :custom, hashy_object: {
    name: HashValidator::Validations::Optional.new("string"),
    quantity: HashValidator.multiple("numeric"),
    active: "boolean",
  }
end
