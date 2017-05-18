PKG ?=
RCP ?=
$(info PACKAGE: "$(PKG)", RECIPE: "$(RCP)", GOALS: "$(MAKECMDGOALS)")

NG3E_TOP=$(shell cd ..; pwd)
export NG3E_TOP
#$(info NG3E_TOP: '$(NG3E_TOP)')
NG3E=$(NG3E_TOP)/tools/ng3e.sh

#$(info PATH: '$(PATH)')
#NEWPATH=$(join $(PATH),$(join :,$(NG3E_TOP)/tools)))
#$(info NEWPATH: '$(NEWPATH)')
#PATH:=$(NEWPATH)
#export PATH
#$(info PATH: '$(PATH)')

all: help

test:
	(cd $(PKG) && $(NG3E) $@ $(RCP))



build:
	(cd $(PKG) && $(NG3E) $@ $(RCP))

pack:
	(cd $(PKG) && $(NG3E) $@ $(RCP))

clean:
	(cd $(PKG) && $(NG3E) $@ $(RCP))

distclean:
	(cd $(PKG) && $(NG3E) $@ $(RCP))

release:
	(cd $(PKG) && $(NG3E) $@ $(RCP))

deploy:
	(cd $(PKG) && $(NG3E) $@ $(RCP))

help:
	@echo ""
	@echo "This is top level NG3E Makefile used for building and packaging modules"
	@echo ""
	@echo "Usage:"
	@echo ""
	@echo " make build PKG=<package name> RCP=<recipe name>         fetch the source and perform a build"
	@echo " make pack PKG=<package name> RCP=<recipe name>          pack the build result in compressed TAR file"
	@echo " make clean PKG=<package name> RCP=<recipe name>         clean the source tree"
	@echo " make distclean PKG=<package name> RCP=<recipe name>     clean the source tree and remove staged files"
	@echo " make release PKG=<package name> RCP=<recipe name>       build and pack all versions of the module"
	@echo ""
	@echo ""
	@echo "List of known modules:"
	@echo ""
	@ls -1 -d */ | sed 's#/##'
