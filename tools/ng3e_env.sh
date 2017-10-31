#!/bin/bash
#
# Usage: import into other ng3e scripts to setup environment
#
# Note: NG3E_TOP has to set externally!

if [ -z "$NG3E_TOP" ]; then
  echo "Aborting: NG3E_TOP not set, do something like:"
  echo "export NG3E_TOP=\$(pwd)"
  exit 1
fi

# include common functions
source ng3e_lib.sh

NG3E_PKGS=$NG3E_TOP/packages
NG3E_STAGE=$NG3E_TOP/stage
NG3E_POOL=$NG3E_TOP/pool
NG3E_ROOT=$NG3E_TOP/root
NG3E_TOOLS=$NG3E_TOP/tools
if [ ! -d "$NG3E_PKGS" ]; then
	__abort "Must be started from ng3e root!"
fi
if [ ! -d "$NG3E_TOOLS" ]; then
	__abort "Must be started from ng3e root!"
fi

# enter the top folder
cd $NG3E_TOP

__dbg "NG3E environment & library sourced .."
