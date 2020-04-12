# Constants
XDG_DATA_HOME ?= $(HOME)/.local/share
binpath := $(HOME)/.local/bin/pbb
comppath := $(XDG_DATA_HOME)/bash-completion/completions/pbb
datapath := $(XDG_DATA_HOME)/pbb/pbb.css

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
	if [ -z "$$(type -p $2)" ]; then \
		echo "Missing dependency $1."; \
		exit 1; \
	fi
endef

ifeq ($(DEVMODE),)
    action := Installing
    cpcmd = install $1 $2
else
    action := Symlinking
    cpcmd = ln --symbolic --force $(PWD)/$1 $2
endif

# Install or symlink a file
# $(call doinstall,name,srcpath,destpath)
define doinstall
	@echo "$(action) $1..."
	@install --directory --mode=0700 $(dir $3)
	@$(call cpcmd,$2,$3)
endef

.PHONY: install ## Install (DEVMODE=1: symlink) pbb, assets and tab completion
install:
	$(call checkdep,Pandoc,pandoc)
	$(call checkdep,Git,git)
	$(call checkdep,Sed,sed)
	$(call checkdep,ImageMagick,convert)
	$(call checkdep,Python 3,python3)
	$(call checkdep,Bats,bats)
	$(call doinstall,pbb,pbb,$(binpath))
	$(call doinstall,stylesheet,pbb.css,$(datapath))
	$(call doinstall,tab completion script,completion/pbb,$(comppath))

# Remove a file or symlink
# $(call douninstall,filename)
define douninstall
	echo "Removing $1..." && \
	rm --force $1;
endef

.PHONY: uninstall ## Remove script, data and tab completion files
uninstall:
	@$(foreach p,binpath datapath comppath,$(call douninstall,$($(p))))
ifneq ($(wildcard $(dir $(datapath))),)
	@echo "Removing pbb directory..."
	@rmdir $(dir $(datapath))
endif
