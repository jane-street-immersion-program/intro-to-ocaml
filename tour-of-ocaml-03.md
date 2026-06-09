<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

## Solutions to the [Previous Exercises](./tour-of-ocaml-02.md#exercises)

1.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let even x = x % 2 = 0

   let evens_only xs = List.filter xs ~f:even
   </oxcaml>

2.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let list_of_tuple (a, b, c) = [a; b; c]
   </oxcaml>

3.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let snd3 (a, b, c) = b

   let all_snd3 xs = List.map xs ~f:snd3
   </oxcaml>

In some cases, you might pass through variables without modifying them, like `xs` in some
of the solutions. Instead, you could use _partial application_ to pre-specify some
function arguments, creating a new function with those arguments already set. For
instance:

<oxcaml utop>
open Core

let even x = x % 2 = 0
let evens_only = List.filter ~f:even
</oxcaml>

This partially applies the `List.filter` function to the `~f` argument, returning a
new function of type

```ocaml
int list -> int list
```

# List Patterns Using `match`

The elements of a list can be accessed through pattern matching. List patterns are based
on the two list constructors, `[]` and `::`. Here's a simple example:

<oxcaml utop>
let my_favorite_language (my_favorite :: the_rest) = my_favorite
</oxcaml>

By pattern matching using `::`, we've isolated and named the first element of
the list (`my_favorite`) and the remainder of the list (`the_rest`). If you
know Lisp or Scheme, what we've done is the equivalent of using the functions
`car` and `cdr` to isolate the first element of a list and the remainder of
that list.

As you can see, however, the toplevel did not like this definition and spit
out a warning indicating that the pattern is not exhaustive. This means that
there are values of the type in question that won't be captured by the
pattern. The warning even gives an example of a value that doesn't match the
provided pattern, in particular, `[]`, the empty list.

You can avoid these warnings, and more importantly make sure that your
code actually handles all of the possible cases, by using a `match`
expression instead.

A `match` expression is a kind of juiced-up version of the `switch` statement
found in C and Java. It essentially lets you list a sequence of patterns,
separated by pipe characters. (The one before the first case is optional.)
The compiler then dispatches to the code following the first matching
pattern. As we've already seen, the pattern can mint new variables that
correspond to parts of the value being matched.

Here's a new version of `my_favorite_language` that uses `match` and doesn't
trigger a compiler warning:

<oxcaml utop>
let my_favorite_language languages =
  match languages with
  | first :: the_rest -> first
  | [] -> "OCaml" (* A good default! *)
;;

let result = my_favorite_language ["English";"Spanish";"French"]
let try_on_empty = my_favorite_language []
</oxcaml>

The preceding code also includes our first comment. OCaml comments are
bounded by `(*` and `*)` and can be nested arbitrarily and cover multiple
lines. There's no equivalent of C++-style single-line comments that are
prefixed by `//`.

The first pattern, `first :: the_rest`, covers the case where `languages` has
at least one element, since every list except for the empty list can be
written down with one or more `::`'s. The second pattern, `[]`, matches only
the empty list. These cases are exhaustive, since every list is either empty
or has at least one element, a fact that is verified by the compiler.

You may notice above that we match on `first :: the_rest` but then proceed to never
use `the_rest` afterwards. `utop` might let you get away with this,
but the normal OCaml compiler will give a warning that looks like this:

```
Error (warning 27 [unused-var-strict]): unused variable the_rest.
```

Instead, you can use something known as a _wildcard pattern_ here --- the underscore `_`.
This is functionally no different to assigning to a variable named `_` except our compiler
will not complain about it being unused and we cannot use it as a variable later on
(enforcing that whatever it is bound to will not be used). Rewriting this way, the match
statement instead looks like:

```ocaml
match languages with
| first :: _ -> first
...
```

Further, any variable which starts with an `_` will turn off the "unused" compiler warning,
so you can name things you are ignoring as a form of documentation in certain situations.

# Exercises

1. Write a function to determine if a list starts with a given element:

   ```ocaml
   val starts_with : 'a list -> 'a -> equal:('a -> 'a -> bool) -> bool
   ```

   `starts_with` takes a list, an element, and a function (`~equal`) to use to compare
   list elements. In a function definition, you can put a `~` in front of a parameter
   name to make it a labeled parameter.

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)

   (* Tests: *)
   let () = assert (Bool.equal (starts_with [3; 4; 5] 3 ~equal:Int.equal) true)
   let () = assert (Bool.equal (starts_with ["foo"; "bar"; "baz"] "baz" ~equal:String.equal) false)
   </oxcaml>

2. Write a function that takes a list of integers and returns a new list with the first
   two elements replaced by their sum:

   ```ocaml
   val sum_first_two : int list -> int list
   ```

   If the list has fewer than two elements, the list is returned unchanged.

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)

   (* Tests: *)
   let () = assert (List.equal Int.equal (sum_first_two [10; 15; 20; 25]) [25; 20; 25])
   let () = assert (List.equal Int.equal (sum_first_two [17]) [17])
   let () = assert (List.equal Int.equal (sum_first_two (sum_first_two [1; 2; 3])) [6])
   let () = assert (List.is_empty (sum_first_two []))
   </oxcaml>

Continue to the [next page](./tour-of-ocaml-04.md).
