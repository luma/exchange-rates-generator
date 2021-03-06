module ExchangeRatesGenerator
  module Formatters
    class Ruby < Base
      def initialize(currency, rates)
        super(currency, rates)
      end
      
      def default_extension
        self.class.default_extension
      end
      
      def description
        self.class.description
      end
      
      class << self
        def default_extension
          :rb
        end
      
        def description
          "Ruby Formatter"
        end
      end

      protected
      
      def header
        <<-EOS
# -*- encoding : utf-8 -*-
#
# THIS FILE IS AUTOMATICALLY GENERATED USING THE exchange-rates-generator RUBY GEM DO NOT EDIT IT.
#
require 'money'

module ExchangeRates
  class CurrencyNotAvailable < StandardError
  end

  # This Class provides exchange rate conversion from #{@currency.to_s} to various other currencies. The list of
  # currencies that this Class can convert to can be retrieve using the supported_currencies method.
  #
  # This Class also supports integration with the Money Gem, for usage see the use_as_default! method.
  #
  # Generated using the exchange-rates-generator Ruby Gem.
  class #{@currency.to_s}
    class << self
      def base_currency
        :#{@currency.to_s}
      end

      # Retrieves an Array of all the supported currency codes.
      #
      # @return [Array] All supported currency codes
      def supported_currencies
        rates.keys
      end

      # Wires this currency up to use with the Money Gem. It sets it as the default
      # currency.
      #
      # @example
      # #{@currency.to_s}.use_as_default!
      # Money.us_dollar(100).exchange_to("CAD") => Money.ca_dollar(124)
      #
      def use_as_default!
        Money.default_currency = base_currency
        Money.bank = self
        Money
      end

        EOS
      end

      def body
        <<-EOS
      # Retrieves an exchange rate.
      #
      # @param [String, #to_s] The target currency that we want the exchange rate for.
      # @return [Float] The exchange rate
      def get(target_currency)
        rates[normalise_code(target_currency)]
      end
      
      # Retrieves a human readible name for a currency code
      #
      # @param [String, #toString] The target currency that we want the exchange rate for.
      # @return [String] The human readible version of the currency code.
      def name_for_code(code)
        names_and_codes[normalise_code(code)]
      end
      
      # Convert +amount+ from base_currency to +currency+.
      #
      # @param [Float, #to_f] Amount to convert.
      # @param [String, #to_s] The currency we want to convert to.
      # @return [Float] The +amount+ converted to +currency+.
      def convert(amount, currency)
        rate = get(currency) or raise CurrencyNotAvailable, "Can't find required exchange rate"
        rate * amount.to_f
      end

      # Retrieves an exchange rate, this is here to support the Money Gem.
      #
      # @param [String, #to_s] The source currency that we want the exchange rate for. For this class from should always match base_currency.
      # @param [String, #to_s] The target currency that we want the exchange rate for.
      # @return [Float] The exchange rate
      def get_rate(from, to)
        unless from.to_s.upcase.to_sym == :#{@currency.to_s}
          raise CurrencyNotAvailable, "This exchange rate converter can only convert from #{@currency.to_s}"
        end

        get(to)
      end

      # Convert +money+ to +currency+.
      #
      # @param [Money] The amount to convert.
      # @param [String] The currency to convert to.
      # @return [Money] The +amount+ converted to +currency+.
      def exchange(money, currency)
        rate = get_rate(money.currency, currency.to_s) or raise CurrencyNotAvailable, "Can't find required exchange rate"

        Money.new((money.cents * rate).floor, currency.to_s, money.precision)
      end

      # The exchange rates relative to base_currency.
      #
      # @return [Hash] The exchange rates relative to base_currency.
      def rates
        {
          :#{@currency.to_s}    => 1.0,
#{rates.to_a.collect { |rate| "          :#{rate[0].to_s}    => #{rate[1].to_s}" }.join(",\n")}
        }
      end
      
      # Retrieves a Hash of code => name. Where name is the more human readable version of the currency code.
      #
      # @return [Hash] The Hash of codes and names.
      def names_and_codes
        {
          :#{@currency.to_s}    => "#{Currencies.get_name(@currency)}",
#{rates.to_a.collect { |rate| "          :#{rate[0].to_s}    => \"#{Currencies.get_name(rate[0])}\"" }.join(",\n")}
        }
      end
        EOS
      end
      
      def footer
        <<-EOS
      private

      def normalise_code(code)
        code.to_s.upcase.to_sym
      end
    end
  end
end # module ExchangeRates
EOS
      end
    end
  end # module Formatters
end # module ExchangeRatesGenerator