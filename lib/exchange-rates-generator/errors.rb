module ExchangeRatesGenerator
  module Errors
    class ExchangeRatesError < StandardError
    end

    class NotFoundError < ExchangeRatesError
    end

    class UnknownError < ExchangeRatesError
    end

    class MalformedSourceClass < ExchangeRatesError
    end
  
    class CurrencyNotAvailable < ExchangeRatesError
    end
  
    class MalformedFormatterClass < ExchangeRatesError
    end
  end # module Errors
end # module ExchangeRatesGenerator