begin
  require 'yard'
  
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb']
    t.options = [
      '--protected',
      '--files', 'History.txt',
      '--title', 'Generate Exchange Rates',
      '-r', File.dirname(File.dirname(__FILE__)) / 'README.rdoc',
      '--quiet'
    ]
  end
  
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end