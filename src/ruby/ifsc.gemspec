lib = File.expand_path('lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'ifsc'
  s.version     = '0.0.1'
  s.date        = '2016-05-13'
  s.summary     = "IFSC code database to help you validate IFSC codes"
  s.description = "A simple gem by @razorpay to help you validate your IFSC codes. IFSC codes are bank codes within India"
  s.authors     = ['Abhay Rana']
  s.email       = ['nemo@razorpay.com']
  s.files       = ['lib/IFSC.rb', 'test/test_ifsc.rb', 'Rakefile', 'Gemfile', 'ifsc.gemspec']

  s.test_files    = s.files.grep(/^(test|spec|features)/)
  s.require_paths = ['lib']

  s.homepage    = 'https://ifsc.razorpay.com'
  s.license       = 'MIT'

  s.add_development_dependency 'rake', '~> 10.5'
  s.add_development_dependency 'minitest', '~> 5.8'
end