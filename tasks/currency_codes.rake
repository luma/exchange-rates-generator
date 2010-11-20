# -*- encoding : utf-8 -*-
require 'exchange-rates-generator'

namespace :currency do 
  desc "Generate a new currency codes cache"
  task :generate_currency_codes do
    include ::ExchangeRatesGenerator

    session = Patron::Session.new
    session.timeout = 30000               # 10 secs
    session.connect_timeout = 2000        # 2 secs

    source = "http://www.iso.org/iso/support/currency_codes_list-1.htm"

    ExchangeRatesGenerator.logger.info "Scraping currency codes from #{source}..."
    http_response = session.get(source)

    if ['404', '405', '406', '410'].include?(http_response.status)
      # Not Found, auth failure, etc. Some form of it wasn't there.
      raise Errors::NotFoundError, "The currency codes source seems to be unavailable"
    elsif !['1', '2'].include?(http_response.status.to_s[0..0])
      # Other non-specific failures.
      raise Errors::UnexpectedError, "Error while making a request to #{source}\nResponse: #{http_response.inspect}"
    end

    doc = Nokogiri::HTML.parse(http_response.body)

    currency_hash = {}

    # Scrap the data and deal with any weird inputs. We also collect as entities that have multiple 
    doc.css('#mainContent .col66.fond table tbody>tr').collect do |currency|
      entity, name, code, numerical_code = currency.css("td")

      unless entity == nil        
        entity = parse_field(entity)
        code = parse_field(code)
        name = parse_field(name)

        unless (entity.blank? || code.blank?)
          entity = entity.humanize.gsub(/\b('?[a-z])/) { $1.capitalize }

          # Handle multiple currency codes per entity (e.g. US Dollar, US Dollar (Same day), and US Dollar (Next day))
          codes = code.split(/\n+/)
          names = name.split(/\n+/)

          0.upto(codes.length - 1) do |i|
            name = names[i].humanize.gsub(/\b('?[a-z])/) { $1.capitalize }
            currency_hash[codes[i].to_s] ||= [name, []]
            currency_hash[codes[i].to_s][1] << entity
          end      
        end
      end
    end

    currencies = []
    currency_hash.each do |code, currency|
      entities = currency[1].collect {|entity| "\"#{entity}\"" }.join(", ")
      currencies << "'#{code}' => [\"#{currency[0]}\", [#{entities}]]"
    end

    # Sort them a-z to make the code easier to read
    currencies.sort! do |c1, c2|
      c1.split(' => ').first[1..-2] <=> c2.split(' => ').first[1..-2]
    end

    currencies = <<-EOS
# -*- encoding : utf-8 -*-
module ExchangeRatesGenerator
  # Generated using "rake currency:generate_currency_codes" from within the exchange-rates-generator gem.
  # Scraped from http://www.iso.org/iso/support/currency_codes_list-1.htm
  # These are utf-8 so ensure that you correctly setup the necessary encodings in your app
  module Currencies
    def self.get(code)
      return nil if RAW[noramalise_code(code)] == nil
      name, entity = RAW[noramalise_code(code)]
      Currency.new(noramalise_code(code).to_sym, name, entity)
    end

    def self.get_name(code)
      return nil if RAW[noramalise_code(code)] == nil
      RAW[noramalise_code(code)][0]
    end

    private

    def self.noramalise_code(code)
      code.to_s.upcase
    end

    RAW = {
#{currencies.collect {|c| "          #{c}" }.join(",\n")}
    }.freeze

  end # module Currencies
end # module ExchangeRatesGenerator
    EOS

    output_path = File.join(File.dirname(File.dirname(__FILE__)), 'lib/exchange-rates-generator/currencies.rb')
    File.open(output_path, 'w') do |file|
      file.write currencies
    end
  
    puts "Done! The currencies cache has been saved to #{output_path}"
  end

  def parse_field(field)
    # Remove all links...
    field.css('a').unlink

    # Sanitise whats left...
    field.inner_html.gsub(/<br\s*\/?>/i, "\n").strip
  end
end
