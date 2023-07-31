require "rspec"
require "llm_memory/store"
require "llm_memory_pgvector/pgvector_store"

RSpec.describe LlmMemoryPgvector::PgvectorStore do
  let(:store) { described_class.new(index_name: "test_pgvector") }

  describe "#initialize" do
    it "registers the store" do
      expect(LlmMemory::StoreManager.stores[:pgvector]).to eq(described_class)
    end

    it "creates a new PG::Connection" do
      expect(store.instance_variable_get(:@conn)).to be_a(PG::Connection)
    end

    it "creates extension if not exists" do
      # Mock the connection to expect exec with the create extension command
      conn = instance_double("PG::Connection")
      allow(PG::Connection).to receive(:new).and_return(conn)
      allow(conn).to receive(:exec)
      allow(conn).to receive(:type_map_for_results=)
      expect(conn).to receive(:exec).with("CREATE EXTENSION IF NOT EXISTS vector")

      described_class.new
    end
  end

  describe "#create_index" do
    it "executes the correct SQL to create the index" do
      expect(store.instance_variable_get(:@conn)).to receive(:exec).with("CREATE TABLE test_pgvector (id bigserial PRIMARY KEY, content TEXT, metadata JSON, vector vector(1536))")
      store.create_index
    end
  end

  describe "#drop_index" do
    it "executes the correct SQL to drop the index" do
      expect(store.instance_variable_get(:@conn)).to receive(:exec).with("DROP TABLE IF EXISTS test_pgvector")
      store.drop_index
    end
  end

  describe "#add" do
    let(:data) { [{content: "Mike's pen", vector: [1, 2, 3], metadata: {}}] }

    it "executes the correct SQL to add data" do
      expect(store.instance_variable_get(:@conn)).to receive(:exec_params).with("INSERT INTO test_pgvector (content, metadata, vector) VALUES ($1, $2, $3)", ["Mike's pen", "{}", [1, 2, 3]])
      store.add(data: data)
    end
  end

  describe "#search" do
    let(:query) { [1, 2, 3] }
    let(:k) { 3 }

    before do
      result = instance_double("PG::Result")
      allow(result).to receive(:map).and_return([])
      allow(store.instance_variable_get(:@conn)).to receive(:exec_params).and_return(result)
    end

    it "executes the correct SQL to search data" do
      expect(store.instance_variable_get(:@conn)).to receive(:exec_params).with("SELECT *, 1 - (vector <-> '[1, 2, 3]') AS similarity  FROM test_pgvector ORDER BY vector <-> $1 LIMIT 3", [query])
      store.search(query: query, k: k)
    end
  end

  describe "Integration test" do
    it "can add and search" do
      store.drop_index
      store.create_index(dim: 3)
      docs = store.add(data: [{content: "Mike's pen", metadata: {a: "a"}, vector: [1, 1, 1]}, {content: "b", metadata: {b: "b"}, vector: [2, 2, 2]}])
      expect(docs).to eq([
        {"id" => 1, "content" => "Mike's pen", "metadata" => {"a" => "a"}, "vector" => [1.0, 1.0, 1.0]},
        {"id" => 2, "content" => "b", "metadata" => {"b" => "b"}, "vector" => [2.0, 2.0, 2.0]}
      ])
      expect(store.list([1])).to eq([{"id" => 1, "content" => "Mike's pen", "metadata" => {"a" => "a"}, "vector" => [1.0, 1.0, 1.0]}])
      related_docs = store.search(query: [1, 2, 1], k: 1)
      expect(related_docs.first[:content]).to eq("Mike's pen")
      expect(store.delete(docs.first["id"])).to eq(true)
      expect(store.list.size).to eq(1)
      expect(store.delete_all).to eq(true)
      expect(store.list.size).to eq(0)
    end
  end
end
