SHELL = /bin/bash

prefix ?= /usr/local
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
srcdir = Sources
templatesdir = Templates

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
CIBUILDDIR = $(REPODIR)/.ci-build
SOURCES = $(wildcard $(srcdir)/**/*.swift)
TEMPLATES = $(templatesdir)

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
	@mkdir -p "$(libdir)/variants"
	@cp -R "$(TEMPLATES)" "$(libdir)/variants/"

.PHONY: ci
ci:
	@install -d "$(bindir)" "$(libdir)"
	@install "$(CIBUILDDIR)/release/variants" "$(bindir)"
	@mkdir -p "$(libdir)/variants"
	@cp -R "$(TEMPLATES)" "$(libdir)/variants/"

.PHONY: pre-ci
pre-ci: variants
	@cp "$(BUILDDIR)/release/variants" "$(CIBUILDDIR)/release/variants"

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

.PHONY: test
test:
	@swift test
	@xcodebuild test -scheme VariantsCore 

.PHONY: coverage
coverage: test
	@bundle install
	@bundle exec slather coverage --ignore ../**/*/Xcode\* --ignore Tests/\* --scheme VariantsCore Variants.xcodeproj/

.PHONY: lint
lint:
	@swiftlint --strict

.PHONY: validation
validation: lint coverage
	@echo "Ready to go."
