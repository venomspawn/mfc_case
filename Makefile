install:
	bundle install

debug:
	bundle exec bin/irb_debug

test:
	bundle exec rspec --fail-fast

build:
	gem build mfc_case.gemspec

.PHONY: doc
doc:
	bin/json_schemas_to_md
	bundle exec yard doc --quiet

.PHONY: doc_stats
doc_stats:
	bundle exec yard stats --list-undoc
