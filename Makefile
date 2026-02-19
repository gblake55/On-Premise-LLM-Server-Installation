SHELL   := /bin/bash
PYTHON  ?= python3
MKDOCS  ?= mkdocs
PORT    ?= 8080

.PHONY: help install build serve clean distclean

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

install:  ## Install Python dependencies
	$(PYTHON) -m pip install -r requirements.txt

build:  ## Build the static site into site/
	$(MKDOCS) build

serve:  ## Start the dev server on PORT (default 8080)
	$(MKDOCS) serve --dev-addr localhost:$(PORT)

clean:  ## Remove build artifacts
	rm -rf site/

distclean: clean  ## Remove build artifacts and Python caches
	rm -rf __pycache__ .cache
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name '*.pyc' -delete 2>/dev/null || true
