PKG ?=
RCP ?=
$(info PACKAGE: "$(PKG)", RECIPE: "$(RCP)", GOALS: "$(MAKECMDGOALS)")

NG3E_TOP=$(shell cd ..; pwd)
export NG3E_TOP
#$(info NG3E_TOP: '$(NG3E_TOP)')

#$(info PATH: '$(PATH)')
NEWPATH=$(join $(PATH),$(join :,$(NG3E_TOP)/tools)))
#$(info NEWPATH: '$(NEWPATH)')
PATH:=$(NEWPATH)
export PATH
#$(info PATH: '$(PATH)')

all: help
	(echo $$PATH)

test:
	(cd $(PKG) && ng3e.sh $@ $(RCP))



build:
	(cd $(PKG) && ng3e.sh $@ $(RCP))

pack:
	(cd $(PKG) && ng3e.sh $@ $(RCP))

clean:
	(cd $(PKG) && ng3e.sh $@ $(RCP))

distclean:
	(cd $(PKG) && ng3e.sh $@ $(RCP))

release:
	(cd $(PKG) && ng3e.sh $@ $(RCP))

deploy:
	(cd $(PKG) && ng3e.sh $@ $(RCP))

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
