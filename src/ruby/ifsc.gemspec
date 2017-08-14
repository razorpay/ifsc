lib = File.expand_path('lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'ifsc'
  s.version     = '0.0.1'
  s.date        = '2017-08-03'
  s.summary     = 'IFSC code database to help you validate IFSC codes'
  s.description = 'A simple gem by @razorpay to help you validate your IFSC codes. IFSC codes are bank codes within India'
  s.authors     = ['Abhay Rana']
  s.email       = ['nemo@razorpay.com']
  s.files       = ['lib/ifsc.rb', 'spec/ifsc_spec.rb', 'Rakefile', 'Gemfile', 'ifsc.gemspec']

  s.test_files    = s.files.grep(/^(test|spec|features)/)
  s.require_paths = ['lib']

  s.homepage = 'https://ifsc.razorpay.com'
  s.license = 'MIT'

  s.add_runtime_dependency 'httparty', '~> 0.15'

  s.add_development_dependency 'rake', '~> 10.5'
  s.add_development_dependency 'rspec', '~> 3.6'
end
