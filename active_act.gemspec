# frozen_string_literal: true

require_relative "lib/active_act/version"

Gem::Specification.new do |spec|
  spec.name = "active_act"
  spec.version = ActiveAct::VERSION
  spec.authors = ["Magdiel Cardoso"]
  spec.email = ["magdielsilva.contato@gmail.com"]

  spec.summary = "ActiveAct is a gem that provides a framework for building actions in Rails."
  spec.description = "Abstract spare methods from your controllers and models into actions in Ruby with Active Act 🚀"
  spec.homepage = "https://github.com/magdielcardoso/active_act"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.2"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/magdielcardoso/active_act"
  spec.metadata["changelog_uri"] = "https://github.com/magdielcardoso/active_act/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
