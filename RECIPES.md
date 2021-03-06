# Recipe file definitions

Updated: Sep 27 2017, Hinko Kocevar <hinko.kocevar@esss.se>

## Introduction

Recipe is a collection of key=value lines that define package name, version, GIT repository and some other properties.

Keys start with _NG3E_PKG__.

Values can be enclosed with double-quotes ("); double-quotes are mandatory if value contains spaces.

Here is an example of recipe for package named _foo_, with GIT repository tag _R1-0_:

	NG3E_PKG_NAME="foo"
	NG3E_PKG_TAG="R1-0"
	NG3E_PKG_BRANCH=
	NG3E_PKG_SOURCE="https://github.com/hinxx/foo"
	NG3E_PKG_UPSTREAM="https://github.com/another/foo"
	NG3E_PKG_GROUP="modules"
	NG3E_PKG_DEPEND="baz:R1-2"

Package will be placed into folder _foo-R1-0_ and packaged into tarball _foo-R1-0.tar.bz2_.

## Explanation of the keys

### NG3E_PKG_NAME

Defines package name.
Name can contain [a-zA-Z0-9_-] characters.
Name does not have to match GIT repository name.

### NG3E_PKG_TAG

Defines GIT repository _tag_ that will be checked out before build process.
If __NG3E_PKG_TAG__ is empty (or undefined) then build script will look for __NG3E_PKG_BRANCH__ variable.
If __NG3E_PKG_BRANCH__ is also empty (or undefined) build process will abort. 
See also __NG3E_PKG_BRANCH__.

### NG3E_PKG_BRANCH

Defines GIT repository _branch_ that will be checked out before build process.
It is used only if __NG3E_PKG_TAG__ is empty (or undefined), otherwise __NG3E_PKG_BRANCH__ is ignored.
See also __NG3E_PKG_TAG__.

### NG3E_PKG_SOURCE

Defines URL of GIT repository containig package sources.
GIT repository will be automatically checked out before build process.

### NG3E_PKG_UPSTREAM

Define upstream URL of GIT repository, if any.
If set it shall be used to sync the forked GIT repository in order to get upstream updates.

### NG3E_PKG_GROUP

Defines a group that the package belongs to.
Currently _base_ and _modules_ group can be set.

### NG3E_PKG_NEED_LIBS

Defines space separated list of packages that this package needs at build time.
A dependency package definition looks like __package_name:package_version__.
Only first level of dependencies is required, the rest are recursively added.
List can be empty.
See also __NG3E_PKG_NEED_PRODS__.

### NG3E_PKG_NEED_PRODS

Defines space separated list of packages that this package needs at (build and) runtime time.
A dependency package definition looks like __package_name:package_version__.
Only first level of dependencies is required, the rest are recursively added.
If a dependency is listed in __NG3E_PKG_NEED_LIBS__ it does not need to be listed here.
List can be empty.
See also __NG3E_PKG_NEED_LIBS__.
