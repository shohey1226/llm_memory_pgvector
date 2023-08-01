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
      @conn = PG::Connection.new(LlmMemoryPgvector.configuration.pg_url)
      # pp @conn
      registry = PG::BasicTypeRegistry.new.define_default_types
      Pgvector::PG.register_vector(registry)
      @conn.type_map_for_results = PG::BasicTypeMapForResults.new(@conn, registry: registry)
      @conn.exec("CREATE EXTENSION IF NOT EXISTS vector")
    end

    def create_index(dim: 1536)
      @conn.exec("CREATE TABLE #{@index_name} (id bigserial PRIMARY KEY, #{@content_key} TEXT, #{@metadata_key} JSON, #{@vector_key} vector(#{dim}))")
    end

    def index_exists?
      @conn.exec("SELECT 1 FROM #{@index_name}")
      true
    rescue PG::Error
      false
    end

    def drop_index
      @conn.exec("DROP TABLE IF EXISTS #{@index_name}")
    end

    def list(id: [])
      result = if id.empty?
        @conn.exec("SELECT * FROM #{@index_name}")
      else
        placeholders = id.map.with_index(1) { |_, i| "$#{i}" }.join(",")
        @conn.exec_params("SELECT * FROM #{@index_name} WHERE id IN (#{placeholders})", id)
      end
      result.entries
    end

    def delete(id)
      result = @conn.exec_params("DELETE FROM #{@index_name} WHERE id = $1", [id])
      result.cmd_tuples > 0
    end

    def get(id)
      result = @conn.exec_params("SELECT * FROM #{@index_name} WHERE id = $1", [id])
      result.entries.first
    end

    def delete_all
      @conn.exec("DELETE FROM #{@index_name}")
      true
    rescue PG::Error
      false
    end

    # data = [{ content: "", vector: [], metadata: {} },,]
    def add(data: [])
      new_ids = []
      data.each do |row|
        result = @conn.exec_params(
          "INSERT INTO #{@index_name} (#{@content_key}, #{@metadata_key}, #{@vector_key}) VALUES ($1, $2, $3) RETURNING id",
          [row[@content_key.to_sym], row[@metadata_key.to_sym].to_json, row[@vector_key.to_sym]]
        )
        new_ids << result[0]["id"].to_i if result && result[0] && result[0]["id"]
      end
      list(id: new_ids)
    end

    def search(query: [], k: 3)
      result = @conn.exec_params("SELECT *, 1 - (#{@vector_key} <-> '#{query}') AS similarity  FROM #{@index_name} ORDER BY #{@vector_key} <-> $1 LIMIT #{k}", [query])
      result.map { |row|
        {
          content: row["content"],
          metadata: row["metadata"].transform_keys(&:to_sym),
          similarity: row["similarity"]
        }
      }
    end
  end
end
