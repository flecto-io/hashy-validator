# frozen_string_literal: true

class HashyObjectValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    instance_value = HashyValueValidator.new(value, options)

    # Do not validate empty hash
    return if instance_value.value.blank?

    unless instance_value.valid?
      record.errors.add(attribute, instance_value.reason)
      return false
    end

    if instance_value.value.is_a?(Array)
      record.errors.add(attribute, :not_an_object)
      return false
    end

    # force all array entries to have string keys
    # discard keys that do not have validators
    value = instance_value.value.stringify_keys.slice(*instance_value.validations.keys)

    # if boolean found as any of the validations we force value to boolean - if present
    instance_value.boolean_attrs.each do |boolean_attr|
      value[boolean_attr] = HashyValueValidator.get_boolean_value(value[boolean_attr]) if value.key?(boolean_attr)
    end

    # use default hash validator
    validator = HashValidator.validate(value, instance_value.validations)
    unless validator.valid?
      validator.errors.each { |k, v| record.errors.add(attribute, "'#{k}' #{v}") }
    end

    # update the value even if errors found
    # we use send write param so we also support attr_accessor attributes
    record.send("#{attribute}=", value)
  end
end
