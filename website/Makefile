# from https://tech.davis-hansson.com/p/make/
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

DEPLOY_HOST := debian@hamaluik.ca
DEPLOY_ROOT := /var/www/nomdebebe.apps.hamaluik.ca

build: public/style.css
.PHONY: build

# ships whatever is in public/ as-is; run `make build` first if the styles changed.
# the server has no rsync, so ship a tarball over ssh and replace the web root
deploy:
> tar czf - -C public . | ssh $(DEPLOY_HOST) 'set -e; \
>   find $(DEPLOY_ROOT) -mindepth 1 -delete; \
>   tar xzf - -C $(DEPLOY_ROOT)'
> @echo "deployed to https://nomdebebe.apps.hamaluik.ca/"
.PHONY: deploy

clean:
> rm -f public/style.css
.PHONY: clean

public/style.css: $(shell find style -type f)
> sass --style=compressed --no-source-map style/style.scss public/style.css

