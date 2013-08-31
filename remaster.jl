#!/usr/bin/env julia

include(joinpath(JULIA_HOME,"../../base/pkg1.jl"))
using Pkg1.Metadata

const fixed = Version("julia",v"0.1")

readchomp(`git rev-parse --symbolic-full-name --abbrev-ref HEAD`) == "devel" ||
    error("not on devel branch.")
success(`git diff --quiet HEAD`) ||
    error("git state not clean.")

for pkg in eachline(`ls`)
    pkg = chomp(pkg)
    isdir(pkg) && isfile("$pkg/url") || continue
    vers = String[]
    for ver in eachline(`ls $pkg/versions`)
        ver = chomp(ver)
        ismatch(Base.VERSION_REGEX,ver) || continue
        push!(vers,ver)
        isfile("$pkg/versions/$ver/requires") || continue
        reqs = parse_requires("$pkg/versions/$ver/requires")
        for r in reqs
            if r.package == "julia" && !contains(r,fixed)
                run(`rm -rf $pkg/versions/$ver`)
                filter!(v->v!=ver,vers)
            end
        end
        isdir("$pkg/versions/$ver") || continue
        run(`perl -i -ple 's/^\s*(julia\b.*?)\s*$/# $1/' $pkg/versions/$ver/requires`)
    end
    isempty(vers) && run(`rm -rf $pkg`)
end

run(`git add -u`)
tree = readchomp(`git write-tree`)
if success(`git diff --quiet master $tree`)
    run(`git checkout -f`)
    info("no changes to apply to master, still on devel.")
else
    run(`git checkout -f master`)
    run(`git pull`)
    master = readchomp(`git rev-parse master`)
    devel = readchomp(`git rev-parse devel`)
    commit = readchomp(`echo Remaster merge` | `git commit-tree $tree -p $master -p $devel`)
    run(`git reset --hard $commit`)
    info("remastered state committed to master.")
end
