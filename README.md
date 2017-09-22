# Next Generation EEE - NG3E #

Author: Hinko Kocevar <hinko.kocevar@esss.se>

Updated: 2017-06-20

## Goals

Intent is to have better control of the versions used in a given IOC. Also it
would be a good idea to follow the community supported approach in support and
IOC development under EPICS, instead of coming up with custom based tools.

End audience of the NG3E are:
* developers
* integrators
* users


## Developers

Developer would create package definitions (recipes) that are used by the builder tools
to generate version-ed deployable packages. Complete chain of dependencies can be
assessed by looking at the recipe definition.

When a new version of package needs to be built, a new recipe is created and builder tools
then produces version-ed package. Previous versions of the package are always
retained. New version of the package does not implicitly influence existing
dependent modules or IOCs.

Package can be a support module (library) or an IOC. Developers would take example
skeletons of module or IOC to start defining new package.

Packages are then distributed as archives that need to be deployed into NG3E tree.

Source code as well as examples that may come with the original package (from
3rd party) would be preserved and distributed.

Developers are the ones that would have most in-depth understanding of how
NG3E works and is supposed to be used.

## Integrators

Integrator would use packages created by the developers (using builder tools) to
create IOCs. Integrator would deploy desired package (with required dependencies)
for users.

Integrators would be responsible for package updates/upgrades to newer versions.

Integrators would usually not be involved in creating new modules or new versions
of modules; even though there are no limitations in doing so.

## Users

Users would use run the IOCs.

## Features

#### Building

Sources for all packaged are located in GIT repository. Recipe specifies which tag
should be checked out for a given package build.

Intermediate stage folder is used to perform the build.

Dependent modules are looked for in root folder.

Build results are placed into root folder.

#### Packaging

After successful build the source and binaries are packaged into tar.bz2 and put into
pool.

The archives are meant to be used for distribution to integrators and users.

.. WIP ..

#### Updating forked repos

From https://stackoverflow.com/questions/7244321/how-do-i-update-a-github-forked-repository

In your local clone of your forked repository, you can add the original GitHub repository as a "remote". ("Remotes" are like nicknames for the URLs of repositories - origin is one, for example.) Then you can fetch all the branches from that upstream repository, and rebase your work to continue working on the upstream version. In terms of commands that might look like:

	# Add the remote, call it "upstream":

	git remote add upstream https://github.com/whoever/whatever.git

	# Fetch all the branches of that remote into remote-tracking branches,
	# such as upstream/master:

	git fetch upstream

	# Make sure that you're on your master branch:

	git checkout master

	# Rewrite your master branch so that any commits of yours that
	# aren't already in upstream/master are replayed on top of that
	# other branch:

	git rebase upstream/master

If you don't want to rewrite the history of your master branch, (for example because other people may have cloned it) then you should replace the last command with git merge upstream/master. However, for making further pull requests that are as clean as possible, it's probably better to rebase.

If you've rebased your branch onto upstream/master you may need to force the push in order to push it to your own forked repository on GitHub. You'd do that with:

	git push -f origin master

You only need to use the -f the first time after you've rebased.


Also do push tags if needed like so:

	git push --tags





