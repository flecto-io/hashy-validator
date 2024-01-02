require 'hash_validator'

class HashyArrayValidator < ActiveModel::EachValidator
  ValidationContext = Struct.new(:record, :attribute, :value, :validations, :boolean_attrs, :unique_attrs)

  def validate_each(record, attribute, value)
    value = process_value(value)
    return unless value_is_valid?(record, attribute, value)

    validations = extract_validations(options)
    boolean_attrs, unique_attrs = extract_boolean_and_unique_attrs(validations)

    context = ValidationContext.new(record, attribute, value, validations, boolean_attrs, unique_attrs)
    validate_array_entries(context)
  end

  private

  def process_value(value)
    value = [] if value.blank?
    value.is_a?(String) ? parse_json(value) : value
  end

  def parse_json(value)
    JSON.parse(value)
  rescue JSON::ParserError => e
    record.errors.add(attribute, :invalid)
    nil
  end

  def value_is_valid?(record, attribute, value)
    return false unless value.is_a?(Array)

    unless value.all? { |e| e.is_a?(Hash) }
      record.errors.add(attribute, :invalid)
      return false
    end

    true
  end

  def extract_validations(options)
    options.stringify_keys.reject { |_, val| val.is_a?(String) && val == 'unique' }
  end

  def extract_boolean_and_unique_attrs(validations)
    boolean_attrs = extract_boolean_attrs(validations)
    unique_attrs = extract_unique_attrs(validations)

    [boolean_attrs, unique_attrs]
  end

  def extract_boolean_attrs(validations)
    validations.select do |val_attr, val|
      (val.is_a?(HashValidator::Validations::Multiple) && val.validations.include?('boolean')) ||
        (val.is_a?(String) && val == 'boolean')
    end.keys
  end

  def extract_unique_attrs(validations)
    unique_attrs = {}

    validations.each do |val_attr, val|
      next unless val.is_a?(HashValidator::Validations::Multiple) && val.validations.include?('unique')

      unique_attrs[val_attr] ||= []
      new_val = HashValidator::Validations::Multiple.new(val.validations.reject { |v| v == 'unique' })
      validations[val_attr] = new_val.validations.blank? ? nil : new_val
    end

    unique_attrs
  end

  def validate_array_entries(context)
    context.value.each do |entry|
      process_boolean_attributes(entry, context.boolean_attrs)
      process_unique_attributes(context.record, context.attribute, entry, context.unique_attrs)
      validate_entry_with_hash_validator(context.record, context.attribute, entry, context.validations)
    end
  end

  def process_boolean_attributes(entry, boolean_attrs)
    boolean_attrs.each do |boolean_attr|
      entry[boolean_attr] = entry[boolean_attr].to_b if entry.key?(boolean_attr)
    end
  end

  def process_unique_attributes(record, attribute, entry, unique_attrs)
    unique_attrs.keys.each do |unique_attr|
      if unique_attrs[unique_attr].include?(entry[unique_attr])
        record.errors.add(attribute, "'#{unique_attr}' not unique")
      else
        unique_attrs[unique_attr] << entry[unique_attr]
      end
    end
  end

  def validate_entry_with_hash_validator(record, attribute, entry, validations)
    validator = HashValidator.validate(entry, validations)

    unless validator.valid?
      validator.errors.each { |k, v| record.errors.add(attribute, "'#{k.to_s}' #{v}") }
    end
  end
end