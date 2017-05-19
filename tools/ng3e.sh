#!/bin/bash

NG3E_DEBUG=1

##################################################################
#							HELPERS
##################################################################

function __dbg() {
	[ -n "$NG3E_DEBUG" ] && echo "[DBG] $@"
}
function __inf() {
	echo "[INF] $@"
}
function __err() {
	echo "[ERR] $@"
}
function __abort() {
	echo "======================================================="
	echo "[ABORT] $@"
	echo "======================================================="
	exit 1
}
function __in() {
	__dbg "${FUNCNAME[1]} >>>"
}
function __ok() {
	__dbg "${FUNCNAME[1]} <<< OK"
}
function __nok() {
	__abort "${FUNCNAME[1]} <<< $*"
}

function __load_recipe() {
	__in

	rcp="$1"
	[ -z "$rcp" ] && __nok "recipe not specified"
	rcpfile="$rcp.rcp"
	[ ! -f "$rcpfile" ] && __nok "recipe file not found"
	source "$rcpfile"

	set | grep ^NG3E_

	NG3E_PKG_RECIPE="$rcp"
	export NG3E_PKG_RECIPE
	NG3E_PKG_RECIPE_FILE="$rcpfile"
	export NG3E_PKG_RECIPE_FILE
	NG3E_PKG_FULL_NAME="$NG3E_PKG_NAME-$NG3E_PKG_RECIPE"
	export NG3E_PKG_FULL_NAME
	
	__ok
}

function __get_released_base_versions() {
	__in

	tmp=""
	pushd $NG3E_ROOT || __nok "root dir not found"
	for dir in $(ls --color=never | grep ^R); do
		if [ -d "$dir/base" ]; then
			tmp="$tmp $dir"	
		fi
	done
	bases="NG3E_BASE_VERSIONS=\"$tmp\""
	eval "$bases"
	__inf "released base: $NG3E_BASE_VERSIONS"
	popd
	
	__ok
}

function __init() {
	__in

	__get_released_base_versions
	__load_recipe "$RCP"
	for d in "$NG3E_STAGE" "$NG3E_POOL" "$NG3E_ROOT"; do
		[ ! -d "$d" ] && mkdir -p "$d"
	done

	__ok
}

function __clone() {
	__in

	arg="$1"
	[ -z "$arg" ] && __nok "missing argument"
	dir="$NG3E_STAGE/$arg"
	
	if [ ! -d "$dir" ]; then
		git clone "$NG3E_PKG_SOURCE" "$dir" || __nok "clone failed"
	fi

	__ok
}

function __checkout() {
	__in

	arg="$1"
	[ -z "$arg" ] && __nok "missing argument"
	dir="$NG3E_STAGE/$arg"
	[ ! -d "$dir" ] && __nok "src dir not found"

	pushd "$dir" || __nok "cd to src dir failed"
	ver=$(git describe --tags --always)
	if [ "$ver" != "$NG3E_PKG_VERSION" ]; then
		git checkout --detach "$NG3E_PKG_VERSION" || __nok "checkout failed"
	fi
	ver=$(git describe --tags)
	[ "$ver" != "$NG3E_PKG_VERSION" ] && __nok "tag checkout failed"
	popd
	
	if [ ! -f "$dir/$NG3E_PKG_RECIPE_FILE" ]; then
		cp "$NG3E_PKG_RECIPE_FILE" "$dir" || __nok "recipe not found"
	fi
	
	__ok
}

function __distclean() {
	__in

	arg="$1"
	[ -z "$arg" ] && __nok "missing argument"
	dir="$NG3E_STAGE/$arg"
	[ ! -d "$dir" ] && __nok "src dir not found"

	pushd "$dir" || __nok "cd to src dir failed"
	make -j distclean
	popd

	__ok
}

function __compile() {
	__in

	arg="$1"
	[ -z "$arg" ] && __nok "missing argument"
	dir="$NG3E_STAGE/$arg"
	[ ! -d "$dir" ] && __nok "src dir not found"

	pushd "$dir" || __nok "cd to src dir failed"
	make -j || __nok "compile failed"
	popd

	__ok
}

function __deploy() {
	__in

	arg="$1"
	[ -z "$arg" ] && __nok "missing argument"
	dir="$NG3E_STAGE/$arg"
	[ ! -d "$dir" ] && __nok "src dir not found"
	# modules provide package full name as second argument (base does not)
	arg2="$2"
	[ -n "$arg2" ] && arg2="/$arg2"

	archive="$NG3E_PKG_FULL_NAME.tar.bz2"
	rm -f "$NG3E_STAGE/$archive"

	pushd "$NG3E_STAGE"
	tar --exclude="O.*" --exclude-vcs -jcf "$NG3E_STAGE/$archive" "$arg" || __nok "tar stage dir failed"
	popd
	
	if [ ! -f "$NG3E_POOL/$archive" ]; then
		mv "$NG3E_STAGE/$archive" "$NG3E_POOL" || __nok "failed to move archive to pool"
	else
		__inf "archive already in the pool"
	fi

	if [ ! -d "$NG3E_ROOT/$arg$arg2" ]; then
		tar xf "$NG3E_POOL/$archive" -C "$NG3E_ROOT" || __nok "failed to extract archive to root"
	else
		__inf "archive already extracted in the root"
	fi

	__ok
}

function __remove() {
	__in

	arg="$1"
	[ -z "$arg" ] && __nok "missing argument"
	dir="$NG3E_STAGE/$arg"
	[ ! -d "$dir" ] && __nok "src dir not found"

	rm -fr "$dir"
	
	__ok
}

##################################################################
#							BASE
##################################################################

function __distclean_base() {
	__in

	__distclean "$NG3E_PKG_VERSION/base"

	__ok
}

function __devel_base() {
	__in

	__clone "$NG3E_PKG_VERSION/base"
	__distclean "$NG3E_PKG_VERSION/base"

	__ok
}

function __build_base() {
	__in

	__clone "$NG3E_PKG_VERSION/base"
	__distclean "$NG3E_PKG_VERSION/base"
	__checkout "$NG3E_PKG_VERSION/base"
	__compile "$NG3E_PKG_VERSION/base"

	__ok
}

function __release_base() {
	__in

	__build_base
	__deploy "$NG3E_PKG_VERSION/base"
	
	__ok
}

function __remove_base() {
	__in

	__remove "$NG3E_PKG_VERSION/base"
	
	__ok
}

##################################################################
#							MODULE
##################################################################

function __config_module() {
	__in

	arg="$1"
	[ -z "$arg" ] && __nok "missing argument"
	arg2="$2"
	[ -z "$arg2" ] && __nok "missing argument"
	dir="$NG3E_STAGE/$arg"
	[ ! -d "$dir" ] && __nok "src dir not found"
	basedir="$NG3E_STAGE/$arg2/base"
	[ ! -d "$dir" ] && __nok "base dir not found"

	release="$dir/configure/RELEASE"
	[ ! -d "$dir/configure" ] && __nok "configure dir does not exist"

	echo "# Autogenerated by NG3E on $(date)" > $release
	echo >> $release
	echo "## >>> dependencies from the recipe" >> $release
	for dep in $NG3E_PKG_DEPEND; do
		name=$(echo $dep | cut -d: -f1)
		rcp=$(echo $dep | cut -d: -f2)
		pkgdir="$NG3E_STAGE/$arg2/modules/${name}-${rcp}"
		key=$(echo $name | tr [:lower:] [:upper:])
		echo "$key=$pkgdir" >> $release
	done
	echo "## <<< dependencies from the recipe" >> $release
	echo >> $release
	echo "## >>> EPICS base from the recipe" >> $release
	echo "EPICS_BASE=$basedir" >> $release
	echo "## <<< EPICS base from the recipe" >> $release

	echo >> $release

	__ok
}

function __devel_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__clone "$base_ver/modules/$NG3E_PKG_FULL_NAME"
	done

	__ok
}

function __build_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__clone "$base_ver/modules/$NG3E_PKG_FULL_NAME"
		__checkout "$base_ver/modules/$NG3E_PKG_FULL_NAME"
		__config_module "$base_ver/modules/$NG3E_PKG_FULL_NAME" "$base_ver"
		__distclean "$base_ver/modules/$NG3E_PKG_FULL_NAME"
		__compile "$base_ver/modules/$NG3E_PKG_FULL_NAME"
	done

	__ok
}

function __release_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
 		__build_module
		__deploy "$base_ver/modules" "$NG3E_PKG_FULL_NAME"
	done

	__ok
}

function __remove_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__remove "$base_ver/modules/$NG3E_PKG_FULL_NAME"
	done

	__ok
}

##################################################################
#							TOP
##################################################################

function ng3e_init() {
	__in
	__nok "not implemented"
}

function ng3e_clean() {
	__in

	case $NG3E_PKG_GROUP in
		"bases")	__distclean_base ;;
		"modules")	__distclean_module ;;
		*)			__nok "unknown package group" ;;
	esac

	__ok
}

function ng3e_devel() {
	__in

	case $NG3E_PKG_GROUP in
		"bases")	__devel_base ;;
		"modules")	__devel_module ;;
		*)			__nok "unknown package group" ;;
	esac

	__ok
}

function ng3e_build() {
	__in

	case $NG3E_PKG_GROUP in
		"bases") 	__build_base ;;
		"modules")	__build_module ;;
		*)			__nok "unknown package group" ;;
	esac

	__ok
}

function ng3e_release() {
	__in

	case $NG3E_PKG_GROUP in
		"bases") 	__release_base ;;
		"modules")	__release_module ;;
		*)			__nok "unknown package group" ;;
	esac

	__ok
}

function ng3e_remove() {
	__in

	case $NG3E_PKG_GROUP in
		"bases")	__remove_base ;;
		"modules")	__remove_module ;;
		*)			__nok "unknown package group" ;;
	esac

	__ok
}

##################################################################
#							MAIN
##################################################################

function main() {
	__in
	
	__inf "NG3E_TOP    : \"$NG3E_TOP\""
	__inf "NG3E_PKGS   : \"$NG3E_PKGS\""
	__inf "NG3E_STAGE  : \"$NG3E_STAGE\""
	__inf "NG3E_POOL   : \"$NG3E_POOL\""
	__inf "NG3E_ROOT   : \"$NG3E_ROOT\""
	__inf "command     : \"$CMD\""
	__inf "recipe      : \"$RCP\""
	
	__init
	
	case $CMD in
	"clean")
		ng3e_clean
		;;
	"devel")
		ng3e_devel
		;;
	"build")
		ng3e_build
		;;
	"release")
		ng3e_release
		;;
	"remove")
		ng3e_remove
		;;
	*)
		__nok "unknown command"
		;;
	esac

	__ok
}

CMD="$1"
RCP="$2"

main
