# frozen_string_literal: true

class HashyObjectValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    instance_value = HashyValueValidator.new(value, options)
    
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

    # we validate each object in the array
    # if boolean found as any of the validations we force value to boolean - if present
    instance_value.boolean_attrs.each do |boolean_attr|
      value[boolean_attr] = HashyValueValidator.get_boolean_value(t[boolean_attr]) if value.key?(boolean_attr)
    end

    # keep track of unique values and add error if needed
    instance_value.unique_attrs.each_key do |unique_attr|
      if instance_value.unique_attrs[unique_attr].include?(value[unique_attr])
        record.errors.add(attribute, "'#{unique_attr}' not unique")
      else
        instance_value.unique_attrs[unique_attr] << t[unique_attr]
      end
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
