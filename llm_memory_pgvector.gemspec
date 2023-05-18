# frozen_string_literal: true

require_relative "lib/llm_memory_pgvector/version"

Gem::Specification.new do |spec|
  spec.name = "llm_memory_pgvector"
  spec.version = LlmMemoryPgvector::VERSION
  spec.authors = ["Shohei Kameda"]
  spec.email = ["shoheik@cpan.org"]

  spec.summary = "A LLM Memory plugin for pgvector"
  spec.description = "A Ruby plugin for the llm_memory gem which allows it to use a pgvector-powered Postgres database as a vector store."
  spec.homepage = "https://github.com/shohey1226/llm_memory_pgvector"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shohey1226/llm_memory_pgvector"
  spec.metadata["changelog_uri"] = "https://github.com/shohey1226/llm_memory_pgvector/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "llm_memory", "~> 0.1.7"
  spec.add_dependency "pg", "~> 1.5.3"
  spec.add_dependency "pgvector", "~> 0.2.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
