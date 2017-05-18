MODULE ?= 
$(info MODULE: $(MODULE), GOALS: $(MAKECMDGOALS))

NG3E_TOP=$(shell cd ..; pwd)
export NG3E_TOP
$(info NG3E_TOP: '$(NG3E_TOP)')

#$(info PATH: '$(PATH)')
NEWPATH=$(join $(PATH),$(join :,$(NG3E_TOP)/tools)))
#$(info NEWPATH: '$(NEWPATH)')
PATH:=$(NEWPATH)
export PATH
$(info PATH: '$(PATH)')

all: help
	(echo $$PATH)

build:
	(echo $$PATH; cd $(MODULE) && ng3e.py $@)

pack:
	(cd $(MODULE) && ng3e.py $@)

clean:
	(cd $(MODULE) && ng3e.py $@)

distclean:
	(cd $(MODULE) && ng3e.py $@)

test:
	(cd $(MODULE) && ng3e.py $@)

help:
	@echo ""
	@echo "This is top level NG3E Makefile used for building and packaging modules"
	@echo ""
	@echo "Usage:"
	@echo ""
	@echo " make build <module>             fetch the source and perform a build"
	@echo " make pack <module>              pack the build result in compressed TAR file"
	@echo " make clean <module>             clean the source tree"
	@echo " make distclean <module>         really clean the source tree"
	@echo ""
	@echo ""
	@echo "List of known modules:"
	@echo ""
	@ls -1 -d */ | sed 's#/##'
