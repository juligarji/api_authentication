$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "api_authentication/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api_authentication"
  s.version     = ApiAuthentication::VERSION
  s.authors     = ["juligarji"]
  s.email       = ["juliangarzon.j@gmail.com"]
  s.homepage    = "https://github.com/juligarji/api_authentication"
  s.summary     = "JWT,Facebook auth2,Twitter auth2"
  s.description = "Provides secure authentication for api-only rails applications."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.6"
  s.add_dependency 'bcrypt', '~> 3.1.7'
  s.add_dependency 'jwt'
  s.add_development_dependency "sqlite3"
end
