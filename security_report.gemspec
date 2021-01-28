lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "security_report/version"

Gem::Specification.new do |spec|
  spec.name          = "security_report"
  spec.version       = SecurityReport::VERSION
  spec.authors       = ["Lucas Dohmen"]
  spec.email         = ["lucas.dohmen@innoq.com"]
  spec.license       = "Apache-2.0"

  spec.summary       = "Generate a security report"
  spec.description   = "Check Ruby projects for dependencies with known security problems"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler-audit", "~> 0.6"
  spec.add_dependency "clap", "~> 1.0"
  spec.add_dependency "terminal-table", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
