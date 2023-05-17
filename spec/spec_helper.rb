# frozen_string_literal: true

require "llm_memory_pgvector"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    LlmMemoryPgvector.configure do |c|
      c.pg_url = ENV.fetch("PGVECTOR_DB_URL", "postgresql://postgres:foobar@localhost")
    end
  end
end
