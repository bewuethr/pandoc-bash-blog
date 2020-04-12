# Constants
SHELL := bash
XDG_DATA_HOME ?= $(HOME)/.local/share
binpath := $(HOME)/.local/bin/pbb
comppath := $(XDG_DATA_HOME)/bash-completion/completions/pbb
datapath := $(XDG_DATA_HOME)/pbb/pbb.css

.PHONY: help ## Display usage instruction; default goal
help:
	@awk '$$3 == "##" {$$1 = ""; sub(/ ## /, "\t"); print}' Makefile \
		| column -s $$'\t' -t

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

# Print message for file already being installed
# $(call installed,fname)
define installed
	@echo "$1 seems to be already installed, not linking it again"
endef

# Create directory and symlink file to target
# $(call dosymlink,destfile,srcfile)
define dosymlink
	@install --directory --mode=0700 $(dir $1)
	@ln -s $(PWD)/$2 $1
endef

# Symlink a file for installation after checking if it exists already
# $(call symlink,name,destfile,srcfile)
define symlink
	@echo "Symlinking $1..."
	$(if $(wildcard $2),$(call installed,$1),$(call dosymlink,$2,$3))
endef

.PHONY: install ## Check dependencies, symlink script, data and tab completion
install:
	$(call checkdep,Pandoc,pandoc)
	$(call checkdep,Git,git)
	$(call checkdep,Sed,sed)
	$(call checkdep,ImageMagick,convert)
	$(call checkdep,Python 3,python3)
	$(call checkdep,Bats,bats)
	$(call symlink,pbb,$(binpath),pbb)
	$(call symlink,stylesheet,$(datapath),pbb.css)
	$(call symlink,tab completion script,$(comppath),completion/pbb)

# Unlink a file
# $(call douninstall,filename)
define douninstall
	echo "Removing symlink $1..." && \
	rm -f $1;
endef

.PHONY: uninstall ## Remove script, data and tab completion symlinks
uninstall:
	@$(foreach p,binpath datapath comppath,$(call douninstall,$($(p))))
ifneq ($(wildcard $(dir $(datapath))),)
	@echo "Removing pbb directory..."
	@rmdir $(dir $(datapath))
endif
