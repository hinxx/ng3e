#!/bin/bash
#
# Source this file from ng3e_env.sh to get all the handy functions.
#

##################################################################
#							HELPERS
##################################################################

function __dbg() {
	[ -n "$NG3E_DEBUG" ] && echo "[DBG] $@"
}
function __inf() {
	echo "[INF] $@"
}
function __wrn() {
	echo "[WRN] $@"
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
function __warn() {
	__wrn "${FUNCNAME[1]} <<< $*"
}

##################################################################
#							WORKERS
##################################################################

function __load_recipe() {
	__in

	rcpfile="$1"
	[ -z "$rcpfile" ] && __nok "recipe file not specified"
	[ ! -f "$rcpfile" ] && __nok "recipe file not found"
	source "$rcpfile"

	set | grep ^NG3E_PKG_

	# figure out version based on supplied tag / branch
	NG3E_PKG_VERSION=
	[ -n "$NG3E_PKG_TAG" ] && NG3E_PKG_VERSION="$NG3E_PKG_TAG"
	[ -z "$NG3E_PKG_VERSION" ] && NG3E_PKG_VERSION="$NG3E_PKG_BRANCH"
	[ -z "$NG3E_PKG_VERSION" ] && __nok "version not set"

	NG3E_PKG_DEPENDS=
	export NG3E_PKG_DEPENDS
	NG3E_PKG_RECIPE="$(basename $rcpfile .rcp)"
	export NG3E_PKG_RECIPE
	NG3E_PKG_RECIPE_FILE="$rcpfile"
	export NG3E_PKG_RECIPE_FILE
	NG3E_PKG_FULL_NAME="$NG3E_PKG_NAME-$NG3E_PKG_RECIPE"
	export NG3E_PKG_FULL_NAME

	__ok
}

function __load_needed_libs() {
	__in

	[ -z "$1" ] && __nok "package name not specified"

	name=$(echo "$1" | cut -f1 -d':')
	ver=$(echo "$1" | cut -f2 -d':')
	rcp="$ver.rcp"

	# get needed libs
	deps=$(grep '^NG3E_PKG_NEED_LIBS=' $NG3E_PKGS/$name/$rcp | cut -f2 -d'=' | sed -e's/"//g')

	for dep in $deps; do
		__inf "LIB depend: $dep"
		NG3E_PKG_DEPENDS="$NG3E_PKG_DEPENDS $dep"
		__load_dependencies "$dep"
	done

	__ok
}

function __load_needed_prods() {
	__in

	[ -z "$1" ] && __nok "package name not specified"

	name=$(echo "$1" | cut -f1 -d':')
	ver=$(echo "$1" | cut -f2 -d':')
	rcp="$ver.rcp"

	# get needed prods
	deps=$(grep '^NG3E_PKG_NEED_PRODS=' $NG3E_PKGS/$name/$rcp | cut -f2 -d'=' | sed -e's/"//g')
	for dep in $deps; do
		__inf "PROD depend: $dep"
		NG3E_PKG_DEPENDS="$NG3E_PKG_DEPENDS $dep"
		__load_dependencies "$dep"
	done

	__ok
}

function __load_dependencies() {
	__in

 	[ -z "$1" ] && __nok "package name not specified"

	__load_needed_libs "$1"
	if [ "$NG3E_PKG_GROUP" = "iocs" ]; then
		__load_needed_prods "$1"
	fi
	deps=$(echo "$NG3E_PKG_DEPENDS" | tr ' ' '\n' | sort | uniq)
	NG3E_PKG_DEPENDS="$(echo $deps | tr '\n' ' ')"

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
	if [ -z "$NG3E_BASE_VERSIONS" -a "$NG3E_PKG_NAME" != "base" ]; then
		__nok "no released bases found in $NG3E_ROOT!"
	else
		__inf "released base: $NG3E_BASE_VERSIONS"
	fi
	popd

	__ok
}

function __create_stamp() {
	__in

	stamp="$1"
	[ -z "$stamp" ] && __nok "stamp not specified"

	if [ ! -f "$stamp" ]; then
		touch "$stamp" || __nok "failed to create stamp $stamp"
		__dbg "created stamp $stamp"
	else
		__dbg "stamp already exists $stamp"
	fi

	__ok
}

function __remove_stamp() {
	__in

	stamp="$1"
	[ -z "$stamp" ] && __nok "stamp not specified"

	if [ ! -f "$stamp" ]; then
		__dbg "stamp absent $stamp"
	else
		rm -f "$stamp"
		__dbg "removed stamp $stamp"
	fi

	__ok
}

function __have_stamp() {
	__in

	stamp="$1"
	[ -z "$stamp" ] && __nok "stamp not specified"

	ret=0
	if [ ! -f "$stamp" ]; then
		__dbg "stamp absent $stamp"
		ret=1
	else
		__dbg "stamp exists $stamp"
	fi

	__ok
	return $ret
}

function __init() {
	__in

	for d in "$NG3E_STAGE" "$NG3E_POOL" "$NG3E_ROOT"; do
		[ ! -d "$d" ] && mkdir -p "$d"
	done

	__load_recipe "$1"
	__load_dependencies "$NG3E_PKG_NAME:$NG3E_PKG_VERSION"
	__inf "final dependency list: $NG3E_PKG_DEPENDS"
	__get_released_base_versions

	for base_ver in $NG3E_BASE_VERSIONS; do
		for d in modules iocs; do
			[ ! -d "$NG3E_STAGE/$base_ver/$d" ] && mkdir -p "$NG3E_STAGE/$base_ver/$d"
			[ ! -d "$NG3E_ROOT/$base_ver/$d" ] && mkdir -p "$NG3E_ROOT/$base_ver/$d"
		done
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

	__have_stamp "$dir/checkout_done.stamp" && return 0

	pushd "$dir" || __nok "cd to src dir failed"
	# is version based on tag or branch?
	if [ -n "$NG3E_PKG_TAG" -a "$NG3E_PKG_TAG" = "$NG3E_PKG_VERSION" ]; then
		ver=$(git describe --tags --always)
		if [ "$ver" != "$NG3E_PKG_VERSION" ]; then
			git checkout --detach "$NG3E_PKG_VERSION" || __nok "checkout failed"
		fi
		ver=$(git describe --tags)
		[ "$ver" != "$NG3E_PKG_VERSION" ] && __nok "tag checkout failed"
	else
		git checkout "$NG3E_PKG_VERSION" || __nok "checkout failed"
	fi
	popd
	__inf "Checked out version (tag/branch): $NG3E_PKG_NAME:$NG3E_PKG_VERSION"

	if [ ! -f "$dir/$NG3E_PKG_RECIPE_FILE" ]; then
		cp "$NG3E_PKG_RECIPE_FILE" "$dir" || __nok "recipe not found"
	fi

	__create_stamp "$dir/checkout_done.stamp" || __nok "failed to create checkout_done.stamp"

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

	__remove_stamp "$dir/config_done.stamp"
	__remove_stamp "$dir/build_done.stamp"

	__ok
}

function __compile() {
	__in

	arg="$1"
	[ -z "$arg" ] && __nok "missing argument"
	dir="$NG3E_STAGE/$arg"
	[ ! -d "$dir" ] && __nok "src dir not found"

	__have_stamp "$dir/build_done.stamp" && return 0

	pushd "$dir" || __nok "cd to src dir failed"
	make -Orecurse -j || __nok "compile failed"
	popd

	__create_stamp "$dir/build_done.stamp" || __nok "failed to create build_done.stamp"

	__ok
}

function __deploy() {
	__in

	arg="$1"
	[ -z "$arg" ] && __nok "missing argument"
	# modules provide package full name as second argument (base does not)
	[ -n "$2" ] && arg="$arg/$2"
	dir="$NG3E_STAGE/$arg"
	[ ! -d "$dir" ] && __nok "src dir not found"

	__have_stamp "$dir/build_done.stamp" || return 1

	rm -fr "$NG3E_ROOT/$arg"
	mkdir -p "$NG3E_ROOT/$arg" || __nok "failed to create folder"

	rsync -a --exclude="O.*" --exclude=".git*" "$NG3E_STAGE/$arg/" "$NG3E_ROOT/$arg/" || __nok "failed to deploy"

	if [ "$NG3E_PKG_GROUP" = "iocs" ]; then
		# change any 'stage' parts of the path to 'root' for envPaths
		find "$NG3E_ROOT/$arg" -name envPaths | xargs sed -i -e 's#/stage/#/root/#'
		# remove unused generated files cdCommands and dllPath.bat
		find "$NG3E_ROOT/$arg" -name cdCommands -o -name dllPath.bat | xargs rm -f
	fi

	__ok
}

function __release() {
	__in

	[ -z "$1" ] && __nok "missing argument"
	arg="$1"
	# modules provide package full name as second argument (base does not)
	[ -n "$2" ] && arg="$arg/$2"
	dir="$NG3E_ROOT/$arg"
	[ ! -d "$dir" ] && __nok "src dir not found"

	archive="$NG3E_PKG_FULL_NAME.tar.bz2"
	rm -f "/tmp/$archive"

	if [ -f "$NG3E_POOL/$archive" ]; then
		__inf "archive $NG3E_POOL/$archive already exists!"
		__ok
		return 0
	fi

	pushd "$NG3E_ROOT"
	tar --exclude="O.*" --exclude-vcs -jcf "/tmp/$archive" "$arg" || __nok "tar stage dir failed"
	popd

# XXX: do we need this?
#      should we be allowed to overwrite existing archive that might be different from
#       one already existing - this should be prevented as current package might alredy
#       be distributed to users!!!!

#	if [ ! -f "$NG3E_POOL/$archive" ]; then
#		mv "$NG3E_STAGE/$archive" "$NG3E_POOL" || __nok "failed to move archive to pool"
#	else
#		__inf "archive already in the pool"
#	fi
	rm -f "$NG3E_POOL/$archive"
	mv "/tmp/$archive" "$NG3E_POOL" || __nok "failed to move archive to pool"

	__ok
}

function __remove() {
	__in

	arg="$1"
	[ -z "$arg" ] && __nok "missing argument"

	# remove stuff from all folders!

	dir="$NG3E_STAGE/$arg"
	[ ! -d "$dir" ] && __wrn "stage dir not found"
	rm -fr "$dir"
	dir="$NG3E_ROOT/$arg"
	[ ! -d "$dir" ] && __wrn "root dir not found"
	rm -fr "$dir"
	file="$NG3E_POOL/$NG3E_PKG_FULL_NAME".tar.bz2
	[ ! -d "$file" ] && __wrn "pool archive not found"
	rm -fr "$file"

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

	__ok
}

function __build_base() {
	__in

	__clone "$NG3E_PKG_VERSION/base"
	__checkout "$NG3E_PKG_VERSION/base"
	__compile "$NG3E_PKG_VERSION/base"
	__deploy "$NG3E_PKG_VERSION/base"

	__ok
}

function __rebuild_base() {
	__in

	__clone "$NG3E_PKG_VERSION/base"
	__distclean "$NG3E_PKG_VERSION/base"
	__checkout "$NG3E_PKG_VERSION/base"
	__compile "$NG3E_PKG_VERSION/base"
	__deploy "$NG3E_PKG_VERSION/base"

	__ok
}

function __release_base() {
	__in

	__build_base
	__release "$NG3E_PKG_VERSION/base"

	__ok
}

function __remove_base() {
	__in

	__remove "$NG3E_PKG_VERSION/base"

	__ok
}

##################################################################
#						MODULE / IOC
##################################################################

function __distclean_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__distclean "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME"
	done

	__ok
}

function __config_module() {
	__in

	[ -z "$1" ] && __nok "missing argument"
	[ -z "$2" ] && __nok "missing argument"
	base_ver="$2"
	dir="$NG3E_STAGE/$arg"
	[ ! -d "$dir" ] && __nok "src dir not found"
	basedir="$NG3E_ROOT/$base_ver/base"
	[ ! -d "$dir" ] && __nok "base dir not found"

	__have_stamp "$dir/config_done.stamp" && return 0

	release="$dir/configure/RELEASE"
	[ ! -d "$dir/configure" ] && __nok "configure dir does not exist"

	echo "# Autogenerated by NG3E on $(date)" > $release
	echo >> $release
	echo "## >>> dependencies from the recipe" >> $release
	for dep in $NG3E_PKG_DEPENDS; do
		name=$(echo $dep | cut -d: -f1)
		rcp=$(echo $dep | cut -d: -f2)
		pkgdir="$NG3E_ROOT/$base_ver/modules/${name}-${rcp}"
		key=$(echo $name | tr [:lower:] [:upper:])
		echo "$key=$pkgdir" >> $release
	done
	echo "## <<< dependencies from the recipe" >> $release
	echo >> $release
	echo "## >>> EPICS base from the recipe" >> $release
	echo "EPICS_BASE=$basedir" >> $release
	echo "## <<< EPICS base from the recipe" >> $release

	echo >> $release

	__create_stamp "$dir/config_done.stamp" || __nok "failed to create config_done.stamp"

	__ok
}

function __devel_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__clone "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME"
	done

	__ok
}

function __build_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__clone "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME"
		__checkout "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME"
		__config_module "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME" "$base_ver"
		__compile "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME"
		__deploy "$base_ver/$NG3E_PKG_GROUP" "$NG3E_PKG_FULL_NAME"
	done

	__ok
}

function __rebuild_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__clone "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME"
		__checkout "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME"
		__config_module "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME" "$base_ver"
		__distclean "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME"
		__compile "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME"
		__deploy "$base_ver/$NG3E_PKG_GROUP" "$NG3E_PKG_FULL_NAME"
	done

	__ok
}

function __release_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
 		__build_module
		__release "$base_ver/$NG3E_PKG_GROUP" "$NG3E_PKG_FULL_NAME"
	done

	__ok
}

function __remove_module() {
	__in

	for base_ver in $NG3E_BASE_VERSIONS; do
		__remove "$base_ver/$NG3E_PKG_GROUP/$NG3E_PKG_FULL_NAME"
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
		bases)
			__distclean_base ;;
		modules|iocs)
			__distclean_module ;;
		*)
			__nok "unknown package group" ;;
	esac

	__ok
}

function ng3e_devel() {
	__in

	case $NG3E_PKG_GROUP in
		bases)
			__devel_base ;;
		modules|iocs)
			__devel_module ;;
		*)
			__nok "unknown package group" ;;
	esac

	__ok
}

function ng3e_build() {
	__in

	case $NG3E_PKG_GROUP in
		bases)
			__build_base ;;
		modules|iocs)
			__build_module ;;
		*)
			__nok "unknown package group" ;;
	esac

	__ok
}

function ng3e_rebuild() {
	__in

	case $NG3E_PKG_GROUP in
		bases)
			__rebuild_base ;;
		modules|iocs)
			__rebuild_module ;;
		*)
			__nok "unknown package group" ;;
	esac

	__ok
}

function ng3e_release() {
	__in

	case $NG3E_PKG_GROUP in
		bases)
			__release_base ;;
		modules|iocs)
			__release_module ;;
		*)
			__nok "unknown package group" ;;
	esac

	__ok
}

function ng3e_remove() {
	__in

	case $NG3E_PKG_GROUP in
		bases)
			__remove_base ;;
		modules|iocs)
			__remove_module ;;
		*)
			__nok "unknown package group" ;;
	esac

	__ok
}

##################################################################
#							MAIN
##################################################################

function usage() {
		echo ""
		echo "Usage:"
		echo ""
		if [ "$2" = "single" ]; then
			echo " bash $1 RECIPE COMMAND"
			echo ""
			echo "     RECIPE ....... path to recipe file (*.rcp)"
			echo ""
			echo "    COMMAND ....... one of the following"
			echo "      devel         fetch the source only"
			echo "      clean         clean the source tree"
			echo "      build         perform a build"
			echo "    rebuild         clean the source tree and perform a build"
			echo "    release         perform rebuild and package"
			echo "     remove         remove files from stage and root"
		elif [ "$2" = "batch" ]; then
			echo " bash $1 RECIPE"
			echo ""
			echo "     RECIPE ....... path to recipe file (*.rcp)"
		fi
		
		echo ""
		echo ""
		echo "List of known packages and versions:"
		echo ""
		pushd $NG3E_PKGS >/dev/null
		printf "%20s ..... %s\n" "PACKAGE" "RECIPE(s)"
		echo "----------------------------------------------------------------------------------"
		pkgs=$(ls -1 -d */ | sed 's#/##')
		for pkg in $pkgs; do
			printf "%20s ..... %s\n" $pkg "$(ls $pkg | tr '\n' ' ')"
		done
		popd >/dev/null
		echo ""
}

function handle_recipe() {
	__in

	# show the environment and arguments
	__inf "NG3E_TOP    : \"$NG3E_TOP\""
	__inf "NG3E_PKGS   : \"$NG3E_PKGS\""
	__inf "NG3E_STAGE  : \"$NG3E_STAGE\""
	__inf "NG3E_POOL   : \"$NG3E_POOL\""
	__inf "NG3E_ROOT   : \"$NG3E_ROOT\""
	__inf "recipe      : \"$1\""
	__inf "command     : \"$2\""

	__init "$1"

	case $2 in
	"clean")
		ng3e_clean
		;;
	"devel")
		ng3e_devel
		;;
	"build")
		ng3e_build
		;;
	"rebuild")
		ng3e_rebuild
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
