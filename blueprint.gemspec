# frozen_string_literal: true

require_relative "lib/blueprint/version"

Gem::Specification.new do |spec|
  spec.name = "blueprint"
  spec.version = Blueprint::VERSION
  spec.authors = ["Ricardo Villagrana"]
  spec.email = ["ricardovillagranal@gmail.com"]

  spec.summary = "Ruby on Rails applicaiton generator."
  spec.description = "Build your app structure from a blueprint."
  spec.homepage = "https://github.com/ricvillagrana/blueprint"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://github.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ricvillagrana/blueprint"
  spec.metadata["changelog_uri"] = "https://github.com/ricvillagrana/blueprint"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end + ["bin/blueprint"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
