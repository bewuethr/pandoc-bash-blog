# Constants
XDG_DATA_HOME ?= $(HOME)/.local/share
binpath := $(HOME)/.local/bin/pbb
comppath := $(XDG_DATA_HOME)/bash-completion/completions/pbb
datapath := $(XDG_DATA_HOME)/pbb/pbb.css
iconpath := $(XDG_DATA_HOME)/pbb/calendar.svg
manpath := $(XDG_DATA_HOME)/man/man1/pbb.1
filterpath := $(XDG_DATA_HOME)/pandoc/filters/dotgraph.lua

.PHONY: help ## Display usage instruction; default goal
help:
	@awk '$$3 == "##" {$$1 = ""; sub(/ ## /, "~"); print}' Makefile \
		| column -s '~' -t

.PHONY: test ## Run Bats test suite
test:
	bats test

# Check if dependency is installed
# $(call checkdep,name,executable)
define checkdep
	@echo "Checking if $1 is installed..."; \
	if [ -z "$$(type -p "$2")" ]; then \
		echo "Missing dependency $1."; \
		exit 1; \
	fi
endef

ifeq ($(DEVMODE),)
    action := Installing
    cpcmd = install "$1" "$2"
else
    action := Symlinking
    cpcmd = ln --symbolic --force "$(PWD)/$1" "$2"
endif

# Install or symlink a file
# $(call doinstall,name,srcpath,destpath)
define doinstall
	@echo "$(action) $1..."
	@install --directory --mode=0700 "$(dir $3)"
	@$(call cpcmd,$2,$3)
endef

.PHONY: install ## Install (DEVMODE=1: symlink) pbb, assets, man page and tab completion
install:
	$(call checkdep,Pandoc,pandoc)
	$(call checkdep,Git,git)
	$(call checkdep,Sed,sed)
	$(call checkdep,ImageMagick,convert)
	$(call checkdep,Python 3,python3)
	$(call checkdep,Bats,bats)
	$(call checkdep,dot,dot)
	$(call doinstall,pbb,pbb,$(binpath))
	$(call doinstall,stylesheet,pbb.css,$(datapath))
	$(call doinstall,calendar icon,assets/calendar.svg,$(iconpath))
	$(call doinstall,man page,man/pbb.1,$(manpath))
	$(call doinstall,tab completion script,completion/pbb,$(comppath))
	$(call doinstall,dot graph filter,pandoc/dotgraph.lua,$(filterpath))

# Remove a file or symlink; the blank line is required!
# $(call douninstall,filename)
define douninstall
	@echo "Removing $1..." && \
	rm --force "$1"

endef

paths := binpath filterpath datapath iconpath manpath comppath

.PHONY: uninstall ## Remove script, filter, data, man page and tab completion files
uninstall:
	$(foreach p,$(paths),$(call douninstall,$($(p))))
ifneq ($(wildcard $(dir $(datapath))),)
	@echo "Removing pbb directory..."
	@rmdir "$(dir $(datapath))"
endif
