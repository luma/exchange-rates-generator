module ExchangeRatesGenerator
  class Currency
    attr_reader :code, :name, :entities
    
    def initialize(code, name, entities)
      @code = code.downcase.to_sym
      @name = name
      @entity = entities
    end
    
    def to_s
      "#{name} (#{@code})"
    end
  end
end # module ExchangeRatesGenerator