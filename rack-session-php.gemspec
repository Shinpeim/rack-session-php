# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "rack-session-php"
  spec.version       = "0.0.1"
  spec.authors       = ["Shinpei Maruyama"]
  spec.email         = ["shinpeim@gmail.com"]
  spec.description   = %q{rack middleware which provides php compatible sessions}
  spec.summary       = %q{rack middleware which provides php competible sessions}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "php_session", "~> 0.3.0"
  spec.add_dependency "rack", "~> 1.5.2"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
