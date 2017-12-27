This is the official METADATA repo for the Julia package manager. See [manual section](http://docs.julialang.org/en/latest/manual/packages) on packages for how to use the package manager to install and develop packages.


Please note our current policies for accepting entries into METADATA.jl:

1. Registered packages must have an [Open Source Initiative approved license](http://opensource.org/licenses), clearly marked via a `LICENSE.md`, `LICENSE`, `COPYING` or similarly named file in the package repository. Packages that wrap proprietary libraries are acceptable if the licenses of those libraries permit open source distribution of the Julia wrapper code.
2. New packages submitted for registration must have at least one tagged version.
3. The lowest package version that will be accepted is v0.0.1. v0.0.0 is no longer permitted.
4. All new tagged versions of packages must have a `REQUIRE` file, which must at a minimum contain a single line like
   ```
   julia 0.6
   ```
   specifying a minimum version of Julia the package is expected to run on. Running `Pkg.tag` copies the contents of a package's `REQUIRE` file into `METADATA.jl/PkgName/versions/1.2.3/requires`.

   A common mistake is to have an entry of the form
   ```
   julia 0.6-
   ```
   with the intention of specifying "version 0.4 and up." On the contrary, this line means "at least a 0.4 pre-release julia."
5. New package version tags must have a minimum Julia version of `0.5` or newer. `0.5-` (0.5 pre-releases) is no longer allowed.
   Exceptions may be granted for `julia 0.4` if package authors are willing to vouch that they still test that their packages work on 0.4.
6. If your package works with Julia 0.6 but not 0.5, then specify `julia 0.6` in your `REQUIRE` file. If the package has had any previous   tags which supported `julia 0.5`, then be sure to change the minor or major version number of the package via `Pkg.tag("PkgName", :minor)` for the first tag that no longer supports `julia 0.5`. This makes it possible to create a separate branch for any future bugfix releases that may be needed for the package on Julia 0.5.
7. We strongly encourage everyone to update METADATA.jl through pull requests, which can be generated for you automatically when you tag a package using Github's UI, provided you have [attobot](https://github.com/integration/attobot) enabled on your repository. Alternatively, you can use the [PkgDev](https://github.com/JuliaLang/PkgDev.jl) package, and its `PkgDev.publish()` function to create PRs. GitHub's pull requests allow us to run basic checks on the metadata entries. METADATA.jl should not be edited directly unless absolutely necessary in an emergency.
8. Do not modify the `sha1` files of existing tags after they have been published by merging to the `JuliaLang/metadata-v2` branch. Bounds can be modified in the `requires` files after the fact, but the code content should remain unchanged for reproducibility of past results.

These policies have been the result of many months of discussion to improve the quality of registered packages and the overall user experience with Julia packages.
