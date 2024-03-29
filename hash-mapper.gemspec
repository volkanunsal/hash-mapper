# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "hash-mapper"
  spec.version       = '0.0.1'
  spec.authors       = ["Volkan Unsal"]
  spec.email         = ["spocksplanet@gmail.com"]

  spec.summary       = %q{Map a Ruby hash into another Ruby hash..}
  spec.description   = %q{Map a Ruby hash into another Ruby hash..}
  spec.homepage      = "https://github.com/volkanunsal/hash-mapper"
  spec.license       = "MIT"
  spec.metadata      = {
    "homepage_uri"      => "https://github.com/volkanunsal/hash-mapper",
    "source_code_uri"   => "https://github.com/volkanunsal/hash-mapper"
  }

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.4.0'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rspec", "~> 3.7"
end
