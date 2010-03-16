module ExchangeRatesGenerator
  class Cacher
    class << self
      def generate(path, currency, source = Sources::Ecb, formatter = Formatters::Ruby)
        File.open(path, 'w') do |file|
          file.puts formatter.new(currency, source.rates_for(currency))
        end
        
        # TODO: Catch some exceptions?

        true
      end
    end
  end
end # module ExchangeRatesGenerator

