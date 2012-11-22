This file in a package repository is a README document to describe the package
in the general style of GitHub READMEs. Over time, we'll build up tooling to
extract appropriate package metadata from git repos formatted like correctly,
including pulling the package description out of this README file.

## Package Manager Overview

The package manager is basically an application written on top of git. You
install packages into a package repo which is a specially laid out git repo
where each submodule is a package and all the packages have mutually
compatible versions. You can have multiple different package repos that have
independent collections of packages, somewhat like Python's virtualenv or
Ruby's RMV. The default package repo location is `~/.julia` but you can
specify a different location by setting the `JULIA_PACKAGES` environment
variable.

The package manager is declarative rather than imperative: you tell it what
packages you need in what ranges of versions, and it figures out a complete
set of packages and versions that you need to fulfill those requirements. This
is rather different than most package managers but is somewhat similar to
Gentoo's portage system.

## Package Repo Layout

`METADATA` is a git submodule where metadata about packages is kept, pulled
from some remote repository like https://github.com/JuliaLang/METADATA.jl.git,
which is the default metadata repo. This is the only submodule in the package
repo that is *not* a itself package (that would cause a bootstrapping issue).

`REQUIRE` is a text file specifying the required packages and versions for the
package repo. Each line specifies a set of required package versions in the
format `pkg v1 v2 ...` where pkg is the name of a package and v1, v2, etc. are
zero or more ascending version numbers in semver.org format. On a line by
itself, `pkg` means any version; `pkg v1` means any version ≥ v1; `pkg v1 v2`
means any version ≥ v1 and < v2; `pkg v1 v2 v3` means any version ≥ v1 and <
v2 or ≥ v3; and so on. Blank lines are ignored and `#` begins a comment. You
can maintain the `REQUIRE` file by hand but there are `Pkg.add` and `Pkg.rm`
commands which will add and remove packages from the file and update packages
afterwards. If there is more than one line for a given package in the
`REQUIRE` file then all of those lines must be satisfied, so the version sets
specifies are effectively intersected.

All *submodules* besides `METADATA` are packages. For example, if you have the
foo package installed, there will be a git submodule at the path foo into
which the appropriate version of the package is checked out. Details most
users don't need to worry about: packages that are installed by the package
manager will have a detached head; if you checkout a branch the package's head
becomes attached and the package manager will consider the checked out version
to be a fixed requirement and will let you manually update the package. This
lets people selectively follow the tip of certain packages, including
maintainers who can work on the package in the package repo version. Moreover,
every user of a package is only a few git commands away from being a
contributor – we'll work on enhancing this functionality to the point where
submitting a bug fix is just a matter of fixing the code and typing a single
package command, which will either submit the patch as an email or a pull
request, depending on the package's metadata.

## Package Manager API

The basic API consists of functions in the `Pkg` module, which can be loaded
with `load("pkg.jl")`.

### Creating & syncing package repos.

Since package repos are git repositories, they automatically have complete
version history and you can clone them and push and pull changes you've made
to them. This makes it easy to keep the set of packages you use in sync on
multiple machines or between many developers using a common setup, by going
through a remote repo stored on a server, e.g. at GitHub (mine is
[here](https://github.com/StefanKarpinski/.julia)).

`Pkg.init([ meta ])`: meta is the URL to a metadata repo; the default one
lives at https://github.com/JuliaLang/METADATA.jl.git and is the official
registry of Julia packages. It's currently empty. One of the first orders of
business is obviously creating some package repos and putting metadata about
them in there so that people can automatically install them using the package
manager.

`Pkg.origin([ url ])`: get or set the remote origin URL that the package repo
pushes to and pulls from. Without a URL argument, it returns the current value
(or nothing if it isn't set, which is the initial state).

`Pkg.push()`: push package repo state to the remote origin URL. This basically
wraps an underlying git call with a little other stuff.

`Pkg.pull()`: pull package repo state from the remote origin URL. Unlike push,
this is a fairly sophisticated routine that not only pulls state from the
remote repo, but also attempts to do intelligent merging when both sides have
diverged in various ways. It should hopefully generally Just Work™.

`Pkg.clone(url)`: clone an existing package repo from a git URL. This ought to
set things up so that repo is the remote origin that you push and pull from.

### Managing installed packages.

The package manager is declarative and the set of packages that need to be
installed is determined in a purely functional manner from package `METADATA`
and the set of requirements in the `REQUIRE` file. It does not matter how a
given set of root requirements was arrived at, with the same metadata, it will
always produce the same set of installed packages.

`Pkg.available()`: prints a list of available package names.

`Pkg.required()`: prints a list of package requirements (i.e the contents of
`REQUIRE`).

`Pkg.installed()`: prints a list of installed package versions.

`Pkg.add(pkgs...)`: add the listed package by name (or package version set
specification) to the `REQUIRE` file and re-resolve the set of packages
necessary to satisfy these requirements. This will typically result in
installing the requested packages and their dependencies, but can also result
in upgrading, downgrading, and even uninstalling of other packages.

`Pkg.rm(pkgs...)`: remove the listed packages by name from the `REQUIRE` file
and re-resolve the set of packages necessary to satisfy these requirements.
This will typically result in uninstalling the named packages and their
dependencies which are no longer necessary, but can also result in upgrading,
downgrading, and installing of other packages.

`Pkg.resolve()`: computes the necessary set of package versions based on the
current `METADATA` and `REQUIRE`, then installs, uninstalls, upgrades and
downgrades packages to meet those requirements. The resolve function considers
packages with attached heads to be fixed points (implicit requirements) and
will not touch them, instead working around those fixed points to make sure
that other package versions are chosen to harmonize with them. The `add()` and
`rm()` functions just edit the `REQUIRE` file and then call resolve() to
update the installed packages.

`Pkg.commit(msg)`: commit the current repo state with the given commit
message. This is necessary when you have edited the `REQUIRE` file manually
and then want to call resolve() to update the installed packages to match.

`Pkg.update()`: fetches new `METADATA` and any new versions upstream repos of
installed packages. Then does a resolve() to update the collection of
installed packages to the latest and greatest set that satisfies the
requirements in `REQUIRE` (which remain the same).
