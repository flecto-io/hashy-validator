# frozen_string_literal: true

class HashyValueValidator
  def initialize(value)
    @value = value.blank? ? [] : value
    @valid = true
    @reason = nil

    check_parse_value
    check_is_array
  end

  def valid?
    @valid
  end

  attr_reader :value, :reason

private

  def check_parse_value
    @value = JSON.parse(@value) if @value.is_a?(String)
  rescue JSON::ParserError
    @valid = false
    @reason = :invalid
  end

  def check_is_array
    return if @value.is_a?(Array)

    @valid = false
    @reason = :not_an_array
  end
end
