SHELL = /bin/bash

ifeq ($(OS),Windows_NT)
	detected_OS := Windows
else
	detected_OS := $(shell uname)
endif

prefix ?= ~/.local
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
srcdir = Sources
templatesdir = Templates
utilsdir = utils

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
PRODUCTDIR = $(BUILDDIR)/apple/Products/Release
SOURCES = $(wildcard $(srcdir)/**/*.swift)
TEMPLATES = $(templatesdir)
UTILS = $(utilsdir)

.DEFAULT_GOAL = all

.PHONY: all
all: variants

variants: $(SOURCES)
	@swift build \
		-c release \
		--arch arm64 \
		--arch x86_64 \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"

.PHONY: install
install: variants
	@install -d $(bindir) $(libdir)
	@install "$(PRODUCTDIR)/variants" $(bindir)
	@mkdir -p $(libdir)/variants
	@cp -R "$(TEMPLATES)" $(libdir)/variants/
	@cp -R "$(UTILS)" $(libdir)/variants/

.PHONY: uninstall
uninstall:
	@rm -rf $(bindir)/variants
	@rm -rf $(libdir)/variants

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/release

.PHONY: clean
clean: distclean
	@rm -rf $(BUILDDIR)

.PHONY: prepare_for_test
prepare_for_test:
	@rm -rf variants.yml

.PHONY: test
test: prepare_for_test
	@swift test
ifeq ($(detected_OS),Darwin) # Mac OSX only
	@xcodebuild test -scheme VariantsCore
endif

.PHONY: coverage
coverage: test
	@gem install bundler
	@bundle install
	@bundle exec slather coverage --ignore ../**/*/Xcode\* --ignore Tests/\* --scheme VariantsCore Variants.xcodeproj/

.PHONY: lint
lint:
	@swiftlint --strict

.PHONY: validation
validation: lint coverage
	@rm -rf variants.yml
	@echo "Ready to go."

.PHONY: ci-validation
ci-validation: test
	@rm -rf variants.yml
	@echo "Ready to go."
