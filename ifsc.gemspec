lib = File.expand_path('src/ruby', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'ifsc'
  s.version     = '1.3.3'
  s.date        = '2018-11-15'
  s.summary     = 'IFSC code database to help you validate IFSC codes'
  s.description = 'A simple gem by @razorpay to help you validate your IFSC codes. IFSC codes are bank codes within India'
  s.authors     = ['Abhay Rana', 'Nihal Gonsalves']
  s.email       = ['contact@razorpay.com']
  s.files       = ['Gemfile', 'ifsc.gemspec'] + `git ls-files src/*.json src/ruby tests/ruby/* tests/*.json *.md`.split("\n")

  s.test_files    = s.files.grep(/^(tests)/)
  s.require_paths = ['src/ruby']

  s.homepage = 'https://ifsc.razorpay.com'
  s.license = 'MIT'

  s.add_runtime_dependency 'httparty', '~> 0.15'

  s.add_development_dependency 'rake', '~> 10.5'
  s.add_development_dependency 'rspec', '~> 3.6'
end
