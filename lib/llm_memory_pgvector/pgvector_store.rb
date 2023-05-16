
require "pg"
require "pgvector"
require "llm_memory/store"

module LlmMemoryPgvector
  class PgvectorStore

    include LlmMemory::Store

    register_store :pgvector

    def initialize(
      index_name: "llm_memory",
      content_key: "content",
      vector_key: "vector",
      metadata_key: "metadata"
    )
      @index_name = index_name
      @content_key = content_key
      @vector_key = vector_key
      @metadata_key = metadata_key
      @conn = PG::Connection.new(LlmMemoryPgvector.configuration.pg_uri)
      #pp @conn
      registry = PG::BasicTypeRegistry.new.define_default_types
      Pgvector::PG.register_vector(registry)
      @conn.type_map_for_results = PG::BasicTypeMapForResults.new(@conn, registry: registry)
      @conn.exec("CREATE EXTENSION IF NOT EXISTS vector")
    end

    def create_index(dim: 1536)
      @conn.exec("CREATE TABLE #{@index_name} (id bigserial PRIMARY KEY, embedding vector(#{dim}))")
    end

    def drop_index
    end

    def add
    end

    def search      
    end    


  end
end