# frozen_string_literal: true

require_relative "llm_memory_pgvector/version"
require_relative "llm_memory_pgvector/pgvector_store"

module LlmMemoryPgvector
  class Error < StandardError; end
  class ConfigurationError < Error; end

  class Configuration
    attr_writer :pg_uri
    
    def initialize
      @pg_uri = nil
    end

    def pg_uri
      return @pg_uri if @pg_uri

      error_text = "Missing Connection URIs See https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING"
      raise ConfigurationError, error_text
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= LlmMemoryPgvector::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
  # LlmMemoryPgvector.configure do |c|
  #   c.pg_uri = "postgresql://postgres:foobar@localhost"
  # end

end
