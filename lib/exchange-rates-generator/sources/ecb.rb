module ExchangeRatesGenerator
  module Sources
    # ECB: European Central Bank home page
    class Ecb < Base
      class << self
        # Retrieves the currency code (as an uppercase symbol) that represents this Source's Base currency.
        #
        # @return [Symbol] The currency code of this Source's base currency
        def base_currency
          :EUR
        end

        # Retrieves a human readable description of the Source.
        #
        # @return [String] The description.
        def description
          "European Central Bank currency feed"
        end

        # Retrieves all the currency rates from the external source, this is a Hash of currency codes and exchange
        # rates. The currency codes will be upcased, Symbols (e.g. :USD, :NZD). The exchange rates will be with
        # respect to the base_currency.
        #
        # @return [Hash] The rates as a Hash of currency codes => exchange rates.
        def all_rates
          session = Patron::Session.new
          session.timeout = 30000               # 10 secs
          session.connect_timeout = 2000        # 2 secs

          ExchangeRatesGenerator.logger.info "Retrieving exchange rates from #{source}..."

          http_response = session.get(source)

          if ['404', '405', '406', '410'].include?(http_response.status)
            # Not Found, auth failure, etc. Some form of it wasn't there.
            raise Errors::NotFoundError, "The exchange rate source file seems to be unavailable"
          elsif !['1', '2'].include?(http_response.status.to_s[0..0])
            # Other non-specific failures.
            raise Errors::UnexpectedError, "Error while making a request to #{source}\nResponse: #{http_response.inspect}"
          end

          convert_to_exchange_rate_hash(http_response.body)
        end

        protected

        # Parse the XML response from the service
        def convert_to_exchange_rate_hash(response_body)
          doc = Nokogiri::HTML.parse(response_body)

          hashed_rates = {}          

          # Normalise and Hash the result
          doc.css('envelope>cube>cube>cube').each do |rate|
            currency  = rate[:currency].upcase.to_sym
            rate      = rate[:rate].to_f
            hashed_rates[currency] = rate
          end

          hashed_rates
        end

        def source
          'http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml'
        end

      end

    end
  end # module Sources
end # module ExchangeRatesGenerator