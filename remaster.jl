#!/usr/bin/env julia

using Pkg.Metadata

const fixed = Version("julia",v"0.1")

run(`git checkout devel`)

for pkg in each_line(`ls`)
	pkg = chomp(pkg)
	isdir(pkg) && isfile("$pkg/url") || continue
   vers = String[]
	for ver in each_line(`ls $pkg/versions`)
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
run(`git checkout -f master`)
run(`git pull`)
master = readchomp(`git rev-parse master`)
devel = readchomp(`git rev-parse devel`)
commit = readchomp(`echo Remaster merge` | `git commit-tree $tree -p $master -p $devel`)
run(`git reset --hard $commit`)
run(`git checkout devel`)
