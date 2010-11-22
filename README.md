# RubyGems Future Speculation

An isolated repo for trying out ridiculous ideas for RubyGems. Don't
get excited, these are just experiments. Briefly:

`Gem::Runtime` represents most of the static stuff that lives on `Gem`
right now. It exposes `gem` and `require` (which are delegated to the
repo), and it manages a `Gem::Repo` and a list of `Gem::Source`es.

`Gem::Repo` manages a local store of gems. It provides methods for
activation and search.

`Gem::Source` is a protocol classes can implement to participate in
installation, remote searches, and dependency resolution. The only
source that's currently implemented is `Gem::Source::Local`, but I'd
expect to see sources for the current marshal API, a JSON API, a set
of Git repos, etc. `Gem::Repo` can also act like a source.

When a gem is pulled from a source, it's delivered as a
`Gem::Installable`, which knows how to install itself in a repo. The
default implementation uses `Gem::Installer`, but one could just as
easily symlink an unpacked directory or something similar.

`Gem::Info` is a very light `Gem::Specification` equivalent. It
contains the minimum amount of information necessary to express
dependencies and the like.

`Gem::Collection` unifies many of the sorting, filtering, and
searching idioms scattered around RubyGems.

## Things to try

    bin/jim ls -e # uses GEM_HOME and GEM_PATH
    bin/jim search -s $GEM_HOME # a local source
    bin/jim install foo -s $GEM_HOME # install from $GEM_HOME to tmp/repo

## Development

Put a clone of RubyGems master in a `rubygems` directory next to this
one. Because this is kind of a meta thing, test deps are
vendored. `rake test` does what you'd expect, but since this is a
scratchpad coverage is very spotty.

Start by looking at and playing with `bin/jim`, a really simple
command-line exerciser. It expects to be run from the root of the
project.

I mostly dev with 1.9.2, but I periodically check things with 1.8.6,
1.8.7, REE 1.8.7, 1.9.1, 1.9.2, MRI's head, JRuby's latest release,
MacRuby's latest release, and Rubinius' latest release.