class HashyValueValidator
    def initialize(value)
      @value = value.blank? ? [] : value
      @valid = true
      @reason = nil
  
      check_parse_value
      check_is_array
      
      @value
    end
  
    def is_valid
      @valid
    end
  
    def value
      @value
    end

    def reason
      @reason
    end
  
    private
  
    def check_parse_value
      begin
        @value = JSON.parse(@value) if @value.is_a?(String)
      rescue JSON::ParserError
        @valid = false
        @reason = :invalid
      end
    end
  
    def check_is_array
      unless @value.is_a?(Array)
        @valid = false
        @reason = :not_an_array
      end
    end
  
    def check_is_hash
      unless value.all?{ |e| e.is_a?(Hash) }
        @valid = false
        @reason = :invalid
      end
    end
  end