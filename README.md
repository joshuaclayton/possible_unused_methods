# PossibleUnusedMethods

This generates a binary which searches through a codebase to identify possible
unused methods or functions. It's geared primarily towards Ruby projects,
although it works well with Elixir projects as well.

## Requirements

* [The Silver Searcher]
* [Git]
* [Ctags] generating a tags file at `APP_ROOT/.git/tags`

[The Silver Searcher]: https://github.com/ggreer/the_silver_searcher
[Git]: https://git-scm.com/
[Ctags]: http://ctags.sourceforge.net/

## Installation

Download the source and run:

```
$ ./bin/build
```

This will generate a `./possible_unused_methods` binary that you can execute
within the root directory of your project.

## Notice

This uses Erlang's `:os.cmd` to execute `ag` (The Silver Searcher), including
interpolation of values from the tags file. If this does not make you
comfortable, don't use this package (or [submit a Pull Request], if you have
ideas of how to fix this).

[submit a Pull Request]: https://github.com/joshuaclayton/possible_unused_methods/pulls

## License

See the [LICENSE].
