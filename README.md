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


## Workflow

### General guidelines

Package source files shall be in the GIT repositories.  
Developer is allowed to build a package either from a _branch_ or a _tag_.  
Builds from branch are considered a work in progress and shall __not__ be distributed.  
Builds from a tag are considered production ready and can be distributed.  
Developer is responsible for deciding when a package can enter production stage.  

### Working with GIT repositories

These are GIT repository of which we are the owner (they are not forked).
No restrictions shall be imposed about the versioning used by the developer(s).


### Working with 3rd party forked GIT repositories

3rd party GIT repositories shall be forked and kept in sync.  
No assumptions shall be made about the versioning used by the upstream developer(s).  
If forked repository needs modifications then a local branch shall be created. 
Local branch is the only place where modifications take place.  
When a branch is considered for a release it needs to be tagged.  
Proposed branch naming schema is to prepend '__ESS-__' to a 3rd party tag name.  
Proposed tag naming schema is to append __'+\<release number\>'__ to a branch.

Examples of valid branch and tag names:

	BRANCH           TAG
	-----------------------------
	ESS-R4-32        ESS-R4-32+1, ESS-R4-32+3
	master           R1-6-1
	ESS-1_4          ESS-1_4+2
	ESS-1.0.7        ESS-1.0.7+6
	ESS-master       ESS-master+2

Examples of tag names:

	ESS-R4-32+1
	ESS-R4-32+2
	ESS-1-6-1+5
	ESS-1_4+7
	ESS-1.0.7+66
	ESS-master+3

The branch or tag name is used in the recipe files to checkout desired source.

### Building from source



#### Updating forked repos

From https://stackoverflow.com/questions/7244321/how-do-i-update-a-github-forked-repository

In your local clone of your forked repository, you can add the original GitHub repository as a "remote".
("Remotes" are like nicknames for the URLs of repositories - origin is one, for example.) Then you can fetch all
the branches from that upstream repository, and rebase your work to continue working on the upstream version.

In terms of commands that might look like:

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

If you don't want to rewrite the history of your master branch, (for example because other people may have cloned it)
then you should replace the last command with git merge upstream/master. However, for making further pull
requests that are as clean as possible, it's probably better to rebase.

If you've rebased your branch onto upstream/master you may need to force the push in order
to push it to your own forked repository on GitHub. You'd do that with:

	git push -f origin master

You only need to use the -f the first time after you've rebased.


Also do push tags if needed like so:

	git push --tags


For EPICS base this had to be done ONCE:

	git clone https://github.com/hinxx/epics-base.git
	git remote add upstream https://github.com/epics-base/epics-base.git
	git fetch upstream 
	
	# sync 3.14 branch
	git checkout origin/3.14 
	git checkout -b 3.14
	git rebase upstream/3.14
	git push -f origin 3.14
	git push --tags
	
	# sync 3.15 branch
	git checkout origin/3.15 
	git checkout -b 3.15
	git rebase upstream/3.15
	git push -f origin 3.15
	git push --tags
	
	# sync 3.16 branch
	git checkout origin/3.16 
	git checkout -b 3.16
	git rebase upstream/3.16
	git push -f origin 3.16
	git push --tags

Now we can follow the instructions above and replace _master_ with either _3.14_, _3.15_ or _3.16_.


#### Creating branch from tag

We should create a separate branch based on a tag each time we want to make changes to source.

After forking upstream project we end up with a copy of GIT repository which we can change as we like.
We are usually not interested in latest, i.e. _master_ branch changes, but in tagged releases.
Many upstream repositories will have tags that mark releases.
If we need to change source we should create a branch, either based on pre-existing branch or tag.
As time goes on, upstream repository will change and will can sync our forked repository against it (see __Updating forked repos__).

From https://stackoverflow.com/questions/10940981/git-how-to-create-a-new-branch-from-a-tag

Here is a git command to create a branch _newbranch_ based on the tag _v1.0_:

	git checkout -b newbranch v1.0


Create ESS branch from a tag (asyn as example):

Sync with upstream first:

	git remote add upstream https://github.com/epics-modules/asyn
	git fetch upstream
	git checkout master
	git rebase upstream/master
	git push -f origin master
	git push --tags
	
	
Create __ESS-R4-32__ branch from __R4-32__ tag:

	git checkout R4-32
	git checkout -b ESS-R4-32
	git push --set-upstream origin ESS-R4-32
