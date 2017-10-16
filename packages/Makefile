PKG ?=
RCP ?=
$(info PACKAGE: "$(PKG)", RECIPE: "$(RCP)", GOALS: "$(MAKECMDGOALS)")

NG3E_TOP    := $(shell cd ..; pwd)
NG3E_PKGS   := $(NG3E_TOP)/packages
NG3E_STAGE  := $(NG3E_TOP)/stage
NG3E_POOL   := $(NG3E_TOP)/pool
NG3E_ROOT   := $(NG3E_TOP)/root

export NG3E_TOP NG3E_PKGS NG3E_STAGE NG3E_POOL NG3E_ROOT
#$(info NG3E_TOP: '$(NG3E_TOP)')

NG3ESH=$(NG3E_TOP)/tools/ng3e.sh

all: help

test:
	(cd $(PKG) && $(NG3ESH) $@ $(RCP))



devel:
	(cd $(PKG) && $(NG3ESH) $@ $(RCP))

build:
	(cd $(PKG) && $(NG3ESH) $@ $(RCP))

rebuild:
	(cd $(PKG) && $(NG3ESH) $@ $(RCP))

clean:
	(cd $(PKG) && $(NG3ESH) $@ $(RCP))

release:
	(cd $(PKG) && $(NG3ESH) $@ $(RCP))

remove:
	(cd $(PKG) && $(NG3ESH) $@ $(RCP))

help:
	@echo ""
	@echo "This is top level NG3E Makefile used for building and packaging modules"
	@echo ""
	@echo "Usage:"
	@echo ""
	@echo " make devel    PKG=<package name> RCP=<recipe name>         fetch the source only"
	@echo " make clean    PKG=<package name> RCP=<recipe name>         clean the source tree"
	@echo " make build    PKG=<package name> RCP=<recipe name>         perform a build"
	@echo " make rebuild  PKG=<package name> RCP=<recipe name>         clean the source tree and perform a build"
	@echo " make release  PKG=<package name> RCP=<recipe name>         perform rebuild and package"
	@echo " make remove   PKG=<package name> RCP=<recipe name>         remove files from stage and root"
	@echo ""
	@echo ""
	@echo "List of known modules:"
	@echo ""
	@ls -1 -d */ | sed 's#/##'
