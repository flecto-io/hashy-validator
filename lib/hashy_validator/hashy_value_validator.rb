# frozen_string_literal: true

class HashyValueValidator
  def initialize(value, options = {})
    @value = value.blank? ? [] : value
    @valid = true
    @reason = nil
    @validations = {}
    @unique_attrs = {}
    @boolean_attrs = []

    check_parse_value
    define_validations(options)
  end

  def valid?
    @valid
  end

  attr_reader :value, :reason, :validations, :unique_attrs, :boolean_attrs

  def self.get_boolean_value(value)
    return true if [true, "true"].include?(value)
    return false if [false, "false"].include?(value)

    nil
  end

  private

  def check_parse_value
    @value = JSON.parse(@value) if @value.is_a?(String)
  rescue JSON::ParserError
    @valid = false
    @reason = :invalid
  end

  def define_validations(options)
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

    @validations = validations
    @unique_attrs = unique_attrs
    @boolean_attrs = boolean_attrs
  end
end
