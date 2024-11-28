# frozen_string_literal: true

require_relative "lib/placate/version"

Gem::Specification.new do |spec|
  spec.name = "placate"
  spec.version = Placate::VERSION
  spec.authors = ["Toby"]
  spec.email = ["toby@darkroom.tech"]

  spec.summary = "Unique job handling for Redis-based job processors"
  spec.description = "Prevents duplicate job execution using Redis locks for any Redis-based job processing system"
  spec.homepage = "https://github.com/tobyond/placate"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "activejob", ">= 7.0"
  spec.add_development_dependency "minitest", "~> 5.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
end
