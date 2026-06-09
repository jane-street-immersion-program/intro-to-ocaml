This tutorial gives an overview of OCaml by walking through a series of
small examples that cover most of the major features of the language. This should provide
a sense of what OCaml can do, without getting too deep into any one topic.

Each page ends with one or more exercises
that you'll complete using in-browser OCaml playgrounds.
As you work through an exercise, type your solution into the playground editor and then
hit ***Run*** (or `Ctrl`+`Enter`) to type-check and evaluate it.

Each exercise has some test cases pre-populated in the editor.
If a test fails, you'll see an `Assert_failure` message pointing at the failing line.
If you want to skip some of the tests,
you can surround them using the OCaml block-comment syntax `(* ... *)`.
You can reset an editor back to its initial state with the
***Reset*** button if you want to start over.

The playgrounds imitate `utop`, the OCaml interactive toplevel that runs in a terminal.
It's worth trying out `utop` in the terminal at least once,
since it can be a handy way to test out small snippets of OCaml code.
So before starting, start up a terminal and run the `utop` command.
Then proceed to [this page](./tour-of-ocaml-00.md) to get started.

## List of Concepts

For reference, here's a summary of the concepts introduced in each section:

- [Part 0](./tour-of-ocaml-00.md)
  - numerical calculations
  - separate operators for `int` and `float`
  - let bindings and variable names
  - defining functions
  - opening `Float.O`
  - `if`-`then`-`else`
- [Part 1](./tour-of-ocaml-01.md)
  - type inference and type annotations
  - generic types
  - tuples
  - destructuring tuples in let bindings
  - labeled tuples
- [Part 2](./tour-of-ocaml-02.md)
  - lists
  - the `::` and `@` operators
  - `List.map`, `List.filter`
  - labeled arguments
- [Part 3](./tour-of-ocaml-03.md)
  - partial application
  - `match`
  - matching on lists
  - wildcard pattern
  - unused variable warning
  - comments
- [Part 4](./tour-of-ocaml-04.md)
  - `function`
  - recursive functions on lists
  - partial match warning
  - or patterns
- [Part 5](./tour-of-ocaml-05.md)
  - tail recursion
  - `List.init`
- [Part 6](./tour-of-ocaml-06.md)
  - options
  - the `^` operator
  - matching on tuples
- [Part 7](./tour-of-ocaml-07.md)
  - defining record types
  - destructuring records
  - field punning
  - accessing record fields
  - defining variant types
  - matching on variants
  - anonymous functions
  - `List.exists`
  - `[%string]`
- [Part 8](./tour-of-ocaml-08.md)
  - functional record updates
  - nested let bindings
  - more `List` functions: `mapi`, `filter_map`, `filter_opt`, `zip_exn`, `take`, `concat`
- [Part 9](./tour-of-ocaml-09.md)
  - the `|>` operator
  - arrays
  - `unit`
  - mutable record fields
  - `List.iter`
- [Part 10](./tour-of-ocaml-10.md)
  - refs

## Acknowledgments

Parts of this tutorial have been adapted directly from [Real World OCaml](https://dev.realworldocaml.org/index.html).
