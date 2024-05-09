require_relative "lib/hashy_validator/version"

Gem::Specification.new do |spec|
    spec.name        = 'hashy_validator'
    spec.version     = HashyValidator::Version::STRING
    spec.date        = '2013-12-31'
    spec.summary     = 'Custom Active Model validator for validating arrays of hashes'
    spec.description = 'The hashy_validator gem provides the HashyArrayValidator, a custom Active Model validator designed to validate arrays of hashes within ActiveRecord model attributes. Utilizing the HashValidator gem, on top of hash_validator gem. The gem includes a comprehensive test suite using the minitest framework.'
    spec.authors     = ['Flecto Team']
    spec.email       = 'dev@flecto.io'

    
    spec.required_ruby_version = '>= 2.0.0'
    spec.require_paths = ["lib"]
    spec.files = Dir["{lib}/**/*"] + ["README.md", "CHANGELOG.md", "hashy_validator.gemspec"]

    spec.add_dependency "activerecord", ">= 6.0.0", "<= 7.2.0"
    spec.add_dependency "hash_validator", "~> 1.1"

    spec.add_development_dependency 'sqlite3', '~> 1.4'
    spec.add_development_dependency 'rake', '~> 13.1.0'
    spec.add_development_dependency 'simplecov', '0.17.1'
    spec.add_development_dependency 'rubocop', '~> 1.59'
    spec.add_development_dependency 'rubocop-shopify', '~> 2.14'

    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3")
        spec.add_development_dependency 'minitest', '>= 5.15.0', '< 5.16'
    else
        spec.add_development_dependency 'minitest', '>= 5.15.0'
    end
end