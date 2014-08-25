# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "rack-session-php"
  spec.version       = "0.1.0"
  spec.authors       = ["Shinpei Maruyama"]
  spec.email         = ["shinpeim@gmail.com"]
  spec.description   = %q{rack middleware which provides php compatible sessions}
  spec.summary       = %q{rack middleware which provides php compatible sessions. multibyte string is supported.}
  spec.homepage      = "https://github.com/Shinpeim/rack-session-php"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "php_session", "= 0.4.1"
  spec.add_dependency "rack", "~> 1.5"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
