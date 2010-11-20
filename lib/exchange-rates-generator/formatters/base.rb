module ExchangeRatesGenerator
  module Formatters
    def self.get(formatter_name)
      begin
        ExchangeRatesGenerator::Formatters.const_get( formatter_name.to_s.demodulize.camelize )
      rescue NameError => e
        nil
      end
    end

    class Base
      attr_reader :currency, :rates

      def initialize(currency, rates)
        @currency = currency.to_s.upcase.to_sym
        @rates = rates
      end
      
      def to_s
        header + body + footer
      end
      
      class << self
        # Returns all Formatters
        #
        # @return [Array]
        #   Array containing all Formatters
        #
        def formatters
          @formatters ||= []
        end

        # Records all new Formatters
        def inherited(formatter)          
          self.formatters << formatter
        end
      end

      protected

      def formatter_classname
        @formatter_classname ||= @currency.to_s.camelize
      end
    end # class Base
  end # module Formatters
end # module ExchangeRatesGenerator
