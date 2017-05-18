#!/bin/bash

NG3E_DEBUG=1

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
	rcp="$rcp.rcp"
	[ ! -f "$rcp" ] && __nok "recipe not found"
	source "$rcp"

	NG3E_PKG_RECIPE="$rcp"
	export NG3E_PKG_RECIPE

	set | grep ^NG3E_

	__ok
}

function __get_full_version() {
	__in

	ver="$NG3E_PKG_VERSION"
	if [ -z "$ver" ]; then
		var="$(grep NG3E_PKG_VERSION $NG3E_PKG_RECIPE)"
		eval "$var"
		ver="$NG3E_PKG_VERSION"
	fi
	[ -z "$ver" ] && __nok "version not set"
	
	fullver="$ver"
	if [ "$NG3E_PKG_GROUP" == "modules" ]; then
		base_ver="$NG3E_PKG_BASE_VERSION"
		if [ -z "$base_ver" ]; then
			var="$(grep NG3E_PKG_BASE_VERSION $NG3E_PKG_RECIPE)"
			eval "$var"
			base_ver="$NG3E_PKG_BASE_VERSION"
		fi
		[ -z "$base_ver" ] && __nok "base version not set"
		fullver="${ver}_${base_ver}"
	fi

	NG3E_PKG_FULL_VERSION="$fullver"
	export NG3E_PKG_FULL_VERSION
		
	NG3E_PKG_BUILD_DIR="build-$NG3E_PKG_FULL_VERSION"
	export NG3E_PKG_BUILD_DIR

	__ok
}

function __clone() {
	__in

	[ -d "src" ] || git clone $NG3E_PKG_SOURCE src || __nok "clone failed"

	__ok
}

function __checkout() {
	__in

	if [ ! -d "$NG3E_PKG_BUILD_DIR" ]; then
		cp -a src "$NG3E_PKG_BUILD_DIR" || __nok "cp src dir to build dir failed"
		pushd "$NG3E_PKG_BUILD_DIR" || __nok "cd to build dir failed"
		git checkout "$NG3E_PKG_VERSION" || __nok "checkout failed"
		popd
	
		cp "$NG3E_PKG_RECIPE" "$NG3E_PKG_BUILD_DIR" || __nok "recipe not found"
	fi
	
	__ok
}

function __clean() {
	__in

	[ ! -d "$NG3E_PKG_BUILD_DIR" ] && return 0

	pushd "$NG3E_PKG_BUILD_DIR" || __nok
	make -j clean
	popd

	rm -fr stage *.tar*

	__ok
}

function __distclean() {
	__in

	rm -fr src build-* stage *.tar*
	
	__ok
}

function __compile() {
	__in

	pushd "$NG3E_PKG_BUILD_DIR" || __nok
	make || __nok
	popd

	__ok
}

function __pack() {
	__in

 	__get_full_version

	[ ! -d "$NG3E_PKG_BUILD_DIR" ] && __nok "no build dir"
	
	fullver="$NG3E_PKG_FULL_VERSION"
	grp="$NG3E_PKG_GROUP"
	namever="$NG3E_PKG_NAME-$fullver"
	stagedir="stage/$grp"
	archive="$namever.tar.bz2"

	rm -f "$archive"
	rm -fr "stage"
	mkdir -p "$stagedir" || __nok "mkdir stage dir failed"

	cp -a "$NG3E_PKG_BUILD_DIR" "$stagedir/$namever" || __nok "cp build to stage dir failed"
	find "$stagedir/$namever" -name O.* -o -name .git | xargs rm -fr

	pushd "stage"
	tar jcf ../$archive $grp || __nok "tar stage dir failed"
	popd
	
	__ok
}

function __move_to_pool() {
	__in

	fullver="$NG3E_PKG_FULL_VERSION"
	archive="$NG3E_PKG_NAME-$fullver.tar.bz2"

	[ ! -f "$archive" ] && __nok "archive not found"
	
	mv "$archive" "$NG3E_TOP/pool" || __nok "failed to move to pool"
	
	__ok
}

##################################################################
#							BASE
##################################################################

function __clean_base() {
	__in

	__get_full_version
	__clean

	__ok
}

function __build_base() {
	__in

	__get_full_version
	__clone
	__clean
	__checkout
	__compile
	__pack

	__ok
}

function __pack_base() {
	__in

	__get_full_version
	__pack

	__ok
}

function __release_base() {
	__in

	__build_base
	__move_to_pool
	
	__ok
}

function __deploy_base() {
	__in

	__get_full_version

	fullver="$NG3E_PKG_FULL_VERSION"
	namever="$NG3E_PKG_NAME-$fullver"
	archive="$namever.tar.bz2"

	[ ! -f "$NG3E_TOP/pool/$archive" ] && __nok "archive not found"
	[ -d "$NG3E_TOP/root/bases/$namever" ] && __nok "already deployed"

	tar xf "$NG3E_TOP/pool/$archive" -C "$NG3E_TOP/root" || __nok "extract archive failed"

	__ok
}

function __get_deployed_base_versions() {
	__in

	pushd $NG3E_TOP/root/bases || __nok "bases dir not found"
	tmp=$(ls -x --color=never -d base-* | sed 's/base-//g')
	bases="NG3E_BASE_VERSIONS=\"$tmp\""
	eval "$bases"
	__inf "deployed base: $NG3E_BASE_VERSIONS"
	popd
	
	__ok
}



##################################################################
#							MODULE
##################################################################

function __config_module_base() {
	__in

	[ -z "$NG3E_PKG_BASE_VERSION" ] && __nok "base version not set"

	basedir="$NG3E_TOP/root/bases/base-$NG3E_PKG_BASE_VERSION"
	[ ! -d "$basedir" ] && __nok "base dir does not exist"

	echo "EPICS_BASE=$basedir" >> $NG3E_PKG_RELEASE_FILE

	__ok
}

function __config_module_depends() {
	__in

	deps=""
	for dep in $NG3E_PKG_DEPEND; do
		pkg=$(echo $dep | cut -d: -f1)
		ver=$(echo $dep | cut -d: -f2)
		pkgdir="$NG3E_TOP/root/modules/${pkg}-${ver}_${NG3E_PKG_BASE_VERSION}"
		key=$(echo $pkg | tr [:lower:] [:upper:])
		echo "$key=$pkgdir" >> $NG3E_PKG_RELEASE_FILE
	done

	__ok
}

function __config_module() {
	__in

	release="$NG3E_PKG_BUILD_DIR/configure/RELEASE"
	[ ! -d "$NG3E_PKG_BUILD_DIR/configure" ] && __nok "configure dir does not exist"
 	NG3E_PKG_RELEASE_FILE="$release"
 	export NG3E_PKG_RELEASE_FILE

	echo "# Autogenerated by NG3E on $(date)" > $NG3E_PKG_RELEASE_FILE
	echo >> $NG3E_PKG_RELEASE_FILE
	__config_module_depends
	echo >> $NG3E_PKG_RELEASE_FILE
	__config_module_base
	echo >> $NG3E_PKG_RELEASE_FILE

	__ok
}

function __clean_module_with_base() {
	__in

	base_ver="$1"
	[ -z "$base_ver" ] && __nok "base version not specified"
	
	NG3E_PKG_BASE_VERSION="$base_ver"
	export NG3E_PKG_BASE_VERSION

	__get_full_version
	__clean

	__ok
}

function __clean_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__clean_module_with_base "$base_ver"
	done

	__ok
}

function __build_module_with_base() {
	__in

	base_ver="$1"
	[ -z "$base_ver" ] && __nok "base version not specified"
	
	NG3E_PKG_BASE_VERSION="$base_ver"
	export NG3E_PKG_BASE_VERSION

	__get_full_version
	__clone
	__checkout
	__config_module
	__clean
	__compile

	__ok
}

function __build_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__build_module_with_base "$base_ver"
	done

	__ok
}

function __pack_module_with_base() {
	__in

	base_ver="$1"
	[ -z "$base_ver" ] && __nok "base version not specified"
	
	NG3E_PKG_BASE_VERSION="$base_ver"
	export NG3E_PKG_BASE_VERSION

	__get_full_version
	__pack

	__ok
}

function __pack_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__pack_module_with_base "$base_ver"
	done

	__ok
}

function __release_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__build_module_with_base "$base_ver"
 		__pack
		__move_to_pool
	done
	
	__ok
}

function __deploy_module_with_base() {
	__in

	base_ver="$1"
	[ -z "$base_ver" ] && __nok "base version not specified"
	
	NG3E_PKG_BASE_VERSION="$base_ver"
	export NG3E_PKG_BASE_VERSION

	__get_full_version

	fullver="$NG3E_PKG_FULL_VERSION"
	namever="$NG3E_PKG_NAME-$fullver"
	archive="$namever.tar.bz2"

	[ ! -f "$NG3E_TOP/pool/$archive" ] && __nok "archive not found"
	[ -d "$NG3E_TOP/root/modules/$namever" ] && __nok "already deployed"

	tar xf "$NG3E_TOP/pool/$archive" -C "$NG3E_TOP/root" || __nok "extract archive failed"

	__ok
}

function __deploy_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__deploy_module_with_base "$base_ver"
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
	"bases")
		__clean_base
		;;
	"modules")
		__clean_module
		;;
	*)
		__nok "unknown package group"
		;;
	esac

	__ok
}

function ng3e_distclean() {
	__in

 	__distclean

	__ok
}

function ng3e_build() {
	__in

	case $NG3E_PKG_GROUP in
	"bases")
		__build_base
		;;
	"modules")
		__build_module
		;;
	*)
		__nok "unknown package group"
		;;
	esac

	__ok
}

function ng3e_pack() {
	__in

	case $NG3E_PKG_GROUP in
	"bases")
		__pack_base
		;;
	"modules")
		__pack_module
		;;
	*)
		__nok "unknown package group"
		;;
	esac

	__ok
}

function ng3e_release() {
	__in

	case $NG3E_PKG_GROUP in
	"bases")
		__release_base
		;;
	"modules")
		__release_module
		;;
	*)
		__nok "unknown package group"
		;;
	esac

	__ok
}

function ng3e_deploy() {
	__in

	case $NG3E_PKG_GROUP in
	"bases")
		__deploy_base
		;;
	"modules")
		__deploy_module
		;;
	*)
		__nok "unknown package group"
		;;
	esac

	__ok
}


##################################################################
#							MAIN
##################################################################

function main() {
	__in
	
	__inf "NG3E top : \"$NG3E_TOP\""
	__inf "command  : \"$CMD\""
	__inf "recipe   : \"$RCP\""
	
	__get_deployed_base_versions
	__load_recipe "$RCP"
	
	case $CMD in
	"clean")
		ng3e_clean
		;;
	"distclean")
		ng3e_distclean
		;;
	"build")
		ng3e_build
		;;
	"pack")
		ng3e_pack
		;;
	"release")
		ng3e_release
		;;
	"deploy")
		ng3e_deploy
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
