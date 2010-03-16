require 'optparse'

module GenerateExchangeRates
  class CLI
    def self.execute(stdout, arguments=[])

      # NOTE: the option -p/--path= is given as an example, and should be replaced in your application.

      options = {
        :path     => nil,
        :source   => 'ecb',
        :format   => 'ruby'
      }
      mandatory_options = %w( currency )

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          This application is wonderful because it can generate helpful classes that can do currency exchange from a single target currency to numerous others.

          Usage: #{File.basename($0)} [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("-v", "--version", String,
                "Displays the current version number of this Gem") { |arg| stdout.puts "#{File.basename($0)} #{ExchangeRatesGenerator::VERSION}"; exit }
        opts.on("-c", "--currency CURRENCY", String,
                "This is the base currency you wish to convert from.") { |arg| options[:currency] = arg }
        opts.on("-p", "--path PATH", String,
                "The is the default output path for the exchange rate converter.",
                "Default: ~/exchange_rates.[format extension]") { |arg| options[:path] = arg }
        opts.on("-s", "--source SOURCE", String,
                "This is the name of the desired Source to retrieve the currency data from.",
                "To get a list of all available Sources using the -l or --list flags.",
                "Default: ecb") { |arg| options[:source] = arg.upcase }
        opts.on("-f", "--format Format", String,
                "This is the name of the desired output format of the exchange rate converter, the choice of format depends on the programming language you intend to use the converter from.",
                "To get a list of all available formats using the -l or --list flags.",
                "Default: ruby") { |arg| options[:format] = arg.upcase }

        opts.on("-l", "--list", "List all available formats and sources") do
          formatters = ExchangeRatesGenerator::Formatters::Base.formatters.collect {|f| "\s\s#{Extlib::Inflection.demodulize(f.to_s)}: #{f.description} (*.#{f.default_extension.to_s})" }.join("\n")
          sources   = ExchangeRatesGenerator::Sources::Base.sources.collect {|s| "\s\s#{Extlib::Inflection.demodulize(s.to_s)}: #{s.description}" }.join("\n")

          stdout.puts <<-EOS
Available Formats:
#{formatters}

Available Sources:
#{sources}
          EOS

          exit
        end
      opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end
      end

      formatter = ::ExchangeRatesGenerator::Formatters.get(options[:format].to_sym)
      unless formatter
        stdout.puts "Sorry, I couldn't find a formatter for the format '#{options[:format]}', use the -l or --list flag to see the complete list of available formats."
        exit
      end

      source = ::ExchangeRatesGenerator::Sources.get(options[:source].to_sym)
      unless source
        stdout.puts "Sorry, I couldn't find the source '#{options[:source]}', use the -l or --list flag to see the complete list of available sources."
        exit
      end

      path = options[:path]
      path ||= "exchange_rates.#{formatter.default_extension.to_s}"

      begin
        File.open(path, 'w') do |file|
          file.write formatter.new(options[:currency], source.rates_for(options[:currency]))
        end

        # TODO: Catch some exceptions?
      rescue ::ExchangeRatesGenerator::ExchangeRatesError => e
        stdout.puts e.message
        exit
      end

      stdout.puts "Exchange rate converted successfully. Find it at: #{path}"
    end
  end
end