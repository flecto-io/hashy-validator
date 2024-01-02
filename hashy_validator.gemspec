Gem::Specification.new do |spec|
    spec.name        = 'hashy_validator'
    spec.version     = '0.0.1'
    spec.date        = '2013-12-31'
    spec.summary     = 'Custom Active Model validator for validating arrays of hashes'
    spec.description = 'The hashy_validator gem provides the HashyArrayValidator, a custom Active Model validator designed to validate arrays of hashes within ActiveRecord model attributes. Utilizing the HashValidator gem, on top of hash_validator gem. The gem includes a comprehensive test suite using the minitest framework.'
    spec.authors     = ['Flecto Team']
    spec.email       = 'dev@flecto.io'

    spec.required_ruby_version = '>= 2.0.0'

    spec.add_dependency "activerecord", version = "~> 6.0.0"
    spec.add_dependency "hash_validator", version = "~> 1.0.0"

    spec.add_development_dependency 'hash_validator', '~> 1.0.0'
    spec.add_development_dependency 'sqlite3', '~> 1.4'
    spec.add_development_dependency 'rake', '~> 13.1.0'

    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3")
        spec.add_development_dependency 'minitest', '>= 5.15.0', '< 5.16'
    else
        spec.add_development_dependency 'minitest', '>= 5.15.0'
    end
end