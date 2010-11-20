module ExchangeRatesGenerator
  module Formatters
    class Javascript < Base
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
          :js
        end

        def description
          "Javascript Formatter"
        end
      end

      protected

      def formatter_classname
        @formatter_classname ||= Extlib::Inflection.underscore(@currency.to_s)
      end

      def header
        <<-EOS
// -*- encoding : utf-8 -*-
//
// THIS FILE IS AUTOMATICALLY GENERATED USING THE exchange-rates-generator RUBY GEM DO NOT EDIT IT.
//

if ( typeof(exchange_rates) === 'undefined' ) {
  var exchange_rates = {};
}

// This Library provides exchange rate conversion from #{@currency.to_s} to various other currencies. The list of
// currencies that this Library can convert to can be retrieve using the supported_currencies method.
//
// Generated using the exchange-rates-generator Ruby Gem.
exchange_rates.#{formatter_classname} = function() {
  function normalise_code(code) {
    return code.toString().toUpperCase();    
  }

        EOS
      end

      def body
        <<-EOS
  return {
    base_currency : function() {
      return '#{@currency.to_s}';
    },

    // Retrieves an Array of all the supported currency codes.
    //
    // @return [Array] All supported currency codes
    supported_currencies : function() {
      return [
#{rates.keys.collect {|c| "        \"#{c}\"" }.join(",\n") }
      ];
    },

    // Retrieves an exchange rate.
    //
    // @param [String, #toString] The target currency that we want the exchange rate for.
    // @return [Float] The exchange rate
    get : function(target_currency) {
      return this.rates()[normalise_code(target_currency)];
    },

    // Retrieves a human readible name for a currency code
    //
    // @param [String, #toString] The target currency that we want the name for.
    // @return [String] The human readible version of the currency code.
    name_for_code : function(code) {
      return this.names_and_codes()[normalise_code(code)];
    },

    // Convert +amount+ from base_currency to +currency+.
    //
    // @param [Float, #to_f] Amount to convert.
    // @param [String, #to_s] The currency we want to convert to.
    // @return [Float] The +amount+ converted to +currency+.
    convert : function(amount, target_currency) {
      var rate = this.get(target_currency);
      if ( !rate ) {
        throw "This exchange rate converter can not convert to " + target_currency;
      }
  
      return rate * parseFloat(amount, 10);
    },

    // The exchange rates relative to base_currency.
    //
    // @return [Hash] The exchange rates relative to base_currency.
    rates : function() {
      return {
        "#{@currency.to_s}"    : 1.0,
#{rates.to_a.collect { |rate| "        \"#{rate[0].to_s}\"    : #{rate[1].to_s}" }.join(",\n")}
      }
    },
    
    // Retrieves a Hash of code => name. Where name is the more human readable version of the currency code.
    //
    // @return [Hash] The Hash of codes and names.
    names_and_codes : function() {
      return {
        "#{@currency.to_s}"    : "#{Currencies.get_name(@currency)}",
#{rates.to_a.collect { |rate| "        \"#{rate[0].to_s}\"    : \"#{Currencies.get_name(rate[0])}\"" }.join(",\n")}
      };
    }
  };
        EOS
      end

      def footer
        <<-EOS
}();
EOS
      end
    end
  end # module Formatters
end # module ExchangeRatesGenerator