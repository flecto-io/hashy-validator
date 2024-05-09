# frozen_string_literal: true

class HashyArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    instance_value = HashyValueValidator.new(value)
    unless instance_value.valid?
      record.errors.add(attribute, instance_value.reason)
      return false
    end

    value = instance_value.value

    # look for boolean and unique validator entries
    unique_attrs = {}
    boolean_attrs = []
    validations =
      # force validator keys to be strings
      options.stringify_keys.map do |val_attr, val|
        is_multiple = val.is_a?(HashValidator::Validations::Multiple)
        if (is_multiple && val.validations.include?("boolean")) || (val.is_a?(String) && val == "boolean")
          boolean_attrs << val_attr
          [val_attr, val]
        elsif is_multiple && val.validations.include?("unique")
          # if unique key present, then remove that entry
          # (since its not from HashValidator standard) and keep its history
          unique_attrs[val_attr] ||= []
          # we have to make a new object to remove the unique entry,
          # because deleting it directly from the original object
          # (val) would result into deleting the verification forever
          new_val = HashValidator::Validations::Multiple.new(val.validations.reject { |v| v == "unique" })
          # return the value
          val.validations.blank? ? nil : [val_attr, new_val]
        elsif val.is_a?(String) && val == "unique"
          # same as above but substring
          unique_attrs[val_attr] ||= []
          nil
        else
          [val_attr, val]
        end
      end.compact.to_h

    # force all array entries to have string keys
    # discard keys that do not have validators
    value = value.map { |e| e.stringify_keys.slice(*validations.keys) }

    # we validate each object in the array
    value.each do |t|
      # if boolean found as any of the validations we force value to boolean - if present
      boolean_attrs.each do |boolean_attr|
        t[boolean_attr] = get_boolean_value(t[boolean_attr]) if t.key?(boolean_attr)
      end

      # keep track of unique values and add error if needed
      unique_attrs.each_key do |unique_attr|
        if unique_attrs[unique_attr].include?(t[unique_attr])
          record.errors.add(attribute, "'#{unique_attr}' not unique")
        else
          unique_attrs[unique_attr] << t[unique_attr]
        end
      end

      # use default hash validator
      validator = HashValidator.validate(t, validations)
      unless validator.valid?
        validator.errors.each { |k, v| record.errors.add(attribute, "'#{k}' #{v}") }
      end
    end

    # update the value even if errors found
    # we use send write param so we also support attr_accessor attributes
    record.send("#{attribute}=", value)
  end

  private

  def get_boolean_value(value)
    return true if [true, "true"].include?(value)
    return false if [false, "false"].include?(value)

    nil
  end
end
