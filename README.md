# LLM Memory pgvector

This is a Ruby plugin for the [llm_memory](https://github.com/shohey1226/llm_memory) gem which allows it to use a pgvector-powered Postgres database as a vector store. [pgvector](https://github.com/pgvector/pgvector) is an open-source vector similarity search tool for Postgres databases. It provides efficient storage and lookup for high-dimensional vector data.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add llm_memory_pgvector 

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install llm_memory_pgvector 

Plese don't forget to add `llm_memory`

    $ bundle add llm_memory

## Configuration

You can configure the Postgres connection URL by setting the `pg_url` in `LlmMemoryPgvector.configuration`.
If you use Rails, please put this in initializers.

```ruby
LlmMemoryPgvector.configuration.pg_url = "postgres://user:password@localhost/mydb"
```

## Usage

This should be used with `llm_memory`. You can refer to [README of llm_memory](https://github.com/shohey1226/llm_memory)

```
# in case it's not loaded, pleaes load them
require llm_memory
require llm_memory_pgvector

hippocampus = LlmMemory::Hippocampus.new(:pgvector, chunk_size: 512)
..
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shohey1226/llm_memory_pgvector. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/shohey1226/llm_memory_pgvector/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LlmMemoryPgvector project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/llm_memory_pgvector/blob/master/CODE_OF_CONDUCT.md).
