SHELL = /bin/bash

prefix ?= /usr/local
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
srcdir = Sources
templatesdir = Templates

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
SOURCES = $(wildcard $(srcdir)/**/*.swift)
TEMPLATES = $(wildcard $(templatesdir)/*)

.DEFAULT_GOAL = all

.PHONY: all
all: variants

variants: $(SOURCES)
	@swift build \
		-c release \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"

.PHONY: install
install: variants
	@install -d "$(bindir)" "$(libdir)"
	@install "$(BUILDDIR)/release/variants" "$(bindir)"
	@mkdir -p "$(libdir)/variants/templates"
	@cp -R "$(TEMPLATES)" "$(libdir)/variants/templates/"

.PHONY: uninstall
uninstall:
	@rm -rf "$(bindir)/variants"
	@rm -rf "$(libdir)/variants"

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/release

.PHONY: clean
clean: distclean
	@rm -rf $(BUILDDIR)
