# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "action_presenter/version"

Gem::Specification.new do |spec|
  spec.name          = "action_presenter-base"
  spec.version       = ActionPresenter::VERSION
  spec.authors       = ["Griffith Chaffee"]
  spec.email         = ["griffithchaffee@gmail.com"]

  spec.summary       = %q{Provides presenter logic to views.}
  spec.description   = %q{Provides presenter logic to views.}
  spec.homepage      = "https://github.com/griffithchaffee/action_presenter-base"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_development_dependency "activesupport", "~> 5.1"
  spec.add_development_dependency "actionview", "~> 5.1"
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "minitest", "~> 5.0"
end
