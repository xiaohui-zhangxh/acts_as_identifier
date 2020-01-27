# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'acts_as_identifier/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'acts_as_identifier'
  spec.version     = ActsAsIdentifier::VERSION
  spec.authors     = ['xiaohui']
  spec.email       = ['xiaohui@tanmer.com']
  spec.homepage    = 'https://github.com/xiaohui-zhangxh/acts_as_identifier'
  spec.summary     = 'Auto-generate unique identifier value for Active Record'
  spec.license     = 'MIT'

  spec.files = Dir['{lib}/**/*', 'MIT-LICENSE', 'README.md']

  spec.add_dependency 'xencoder', '~> 0.1.0'
  spec.add_development_dependency 'rails', '~> 6.0.1'
  spec.add_development_dependency 'sqlite3'
end
