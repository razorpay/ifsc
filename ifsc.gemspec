lib = File.expand_path('src/ruby', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'ifsc'
  s.version     = '1.4.5'
  s.date        = '2019-05-20'
  s.summary     = 'IFSC code database to help you validate IFSC codes'
  s.description = 'A simple gem by @razorpay to help you validate your IFSC codes. IFSC codes are bank codes within India'
  s.authors     = ['Abhay Rana', 'Nihal Gonsalves']
  s.email       = ['contact@razorpay.com']
  s.files       = ['Gemfile', 'ifsc.gemspec'] + `git ls-files src/*.json src/ruby tests/ruby/* tests/*.json *.md`.split("\n")

  s.test_files    = s.files.grep(/^(tests)/)
  s.require_paths = ['src/ruby']

  s.homepage = 'https://ifsc.razorpay.com'
  s.license = 'MIT'

  s.add_runtime_dependency 'httparty', '~> 0.16'

  s.add_development_dependency 'rake', '~> 12.3'
  s.add_development_dependency 'rspec', '~> 3.8'
end
