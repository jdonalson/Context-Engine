SHELL := /bin/bash

.PHONY: up down logs ps restart rebuild index reindex

up:
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f --tail=100

ps:
	docker compose ps

restart:
	docker compose down && docker compose up -d --build

rebuild:
	docker compose build --no-cache

# Index code into Qdrant without dropping the collection
index:
	docker compose run --rm indexer --root /work

# Recreate collection then index from scratch (will remove existing points!)
reindex:
	docker compose run --rm indexer --root /work --recreate

# Watch mode: reindex changed files on save (Ctrl+C to stop)
watch:
	docker compose run --rm --entrypoint python indexer /work/scripts/watch_index.py

# Multi-query re-ranker helper example
rerank:
	docker compose run --rm --entrypoint python indexer /work/scripts/rerank_query.py \
	  --query "chunk code by lines with overlap for indexing" \
	  --query "function to split code into overlapping line chunks" \
	  --language python --under /work/scripts --limit 5

warm:
	docker compose run --rm --entrypoint python indexer /work/scripts/warm_start.py --ef 256 --limit 3

health:
	docker compose run --rm --entrypoint python indexer /work/scripts/health_check.py


