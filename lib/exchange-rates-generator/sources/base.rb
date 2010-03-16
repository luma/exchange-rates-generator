module ExchangeRatesGenerator
  module Sources
    def self.get(source_name)
      Object.full_const_get([self.to_s, Extlib::Inflection.classify(source_name.to_s)].join("::"))
    end

    class Base
      class << self
        # Returns all Sources
        #
        # @return [Array]
        #   Array containing all Sources
        #
        def sources
          @sources ||= []
        end

        # Records all new Sources
        def inherited(source)
          self.sources << source
        end

        # Retrieve a Hash of currency codes and exchange rates, they rates will be relative to +currency_code+
        #
        # @param [String, #to_s] The currency code that the exchange rates will be relative to.
        # @return [Hash] The exchange rates, as a Hash of currency codes and exchange rates.
        def rates_for(currency_code)
          # Retrieve the actual rates from the external source
          rates = all_rates

          adjusted_currency = currency_code.to_s.upcase.to_sym          
          unless rates.include?(adjusted_currency)
            raise Errors::CurrencyNotAvailable, "#{adjusted_currency.to_s} was not available in this Source (#{self.to_s}), please use a different Source"
          end

          adjusted_rates = {}

          # Add the currency we are converting to...
          adjusted_rates[adjusted_currency] = 1.0

          # Work out the exchange from our desired currency to our base currency. So if our base was EUR and we wanted USD this would 
          # be how many Euros are in one US dollar.
          adjustment_factor = 1.0 / rates[adjusted_currency]
          adjusted_rates[base_currency] = adjustment_factor

          # Now remove it, since we've already done it.
          rates.delete(base_currency)

          # Now convert the rest
          rates.each do |currency, rate|
            adjusted_rates[currency] = rate * adjustment_factor
          end

          adjusted_rates
        end
      end
      
    end
  end # module Sources
end # module ExchangeRatesGenerator