<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

## Solutions to the [Previous Exercises](./tour-of-ocaml-01.md#exercises)

1.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let fst3 (a, b, c) = a
   let snd3 (a, b, c) = b
   let trd3 (a, b, c) = c
   </oxcaml>

2.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let distance (~x:x1, ~y:y1) (~x:x2, ~y:y2) =
     Float.sqrt ((x1 -. x2) **. 2. +. (y1 -. y2) **. 2.)
   ;;
   </oxcaml>

# Lists

Where tuples let you combine a fixed number of items, potentially of different types,
lists let you hold any number of items of the same type. Consider the following example:

<oxcaml utop>
let languages = ["OCaml";"Perl";"C"]
</oxcaml>

Note that you can't mix elements of different types in the same list, unlike
tuples:

<oxcaml utop>
let numbers = [3;"four";5]
</oxcaml>

## The `List` Module

`Core` comes with a `List` module that has a rich collection of functions for
working with lists. We can access values from within a module by using dot
notation. For example, this is how we compute the length of a list:

<oxcaml utop>
let languages = ["OCaml";"Perl";"C"]
let number_of_languages = List.length languages
</oxcaml>

Here's something a little more complicated. We can compute the list of the
lengths of each language as follows:

<oxcaml utop>
open Core

let languages = ["OCaml";"Perl";"C"]
let language_name_lengths = List.map languages ~f:String.length
</oxcaml>

`List.map` takes two arguments: a list and a function for transforming the
elements of that list. It returns a new list with the transformed elements
and does not modify the original list.

Notably, the function passed to `List.map` is passed under a _labeled argument_ `~f`.
Labeled arguments are specified by name rather than by position, and thus allow you to
change the order in which arguments are presented to a function without changing its
behavior, as you can see here:

<oxcaml utop>
open Core

let languages = ["OCaml";"Perl";"C"]
let language_name_lengths = List.map ~f:String.length languages
</oxcaml>

## Constructing Lists with `::`

In addition to constructing lists using brackets, we can use the list constructor `::` for
adding elements to the front of a list:

<oxcaml utop>
let languages = ["OCaml";"Perl";"C"]
let more_languages = "French" :: "Spanish" :: languages
</oxcaml>

Here, we're creating a new and extended list, not changing the list we
started with, as you can see below:

<oxcaml utop>
let languages = ["OCaml";"Perl";"C"]
</oxcaml>

## Semicolons Versus Commas

Unlike many other languages, OCaml uses semicolons to separate list elements in lists
rather than commas. Commas, instead, are used for separating elements in a tuple. If you
try to use commas in a list, you'll see that your code compiles but doesn't do quite what
you might expect:

<oxcaml utop>
let list_of_triple = ["OCaml", "Perl", "C"]
</oxcaml>

In particular, rather than a list of three strings, what we have is a
singleton list containing a three-tuple of strings.

This example uncovers the fact that commas create a tuple, even if there are
no surrounding parens. So, we can write:

<oxcaml utop>
let int_triple = 1,2,3
</oxcaml>

to allocate a tuple of integers. This is generally considered poor style and
should be avoided.

The bracket notation for lists is really just syntactic sugar for `::`. Thus,
the following declarations are all equivalent. Note that `[]` is used to
represent the empty list and that `::` is right-associative:

<oxcaml utop>
let list1 = [1; 2; 3]
let list2 = 1 :: (2 :: (3 :: []))
let list3 = 1 :: 2 :: 3 :: []
</oxcaml>

The `::` constructor can only be used for adding one element to the front of
the list, with the list terminating at `[]`, the empty list. There's also a
list concatenation operator, `@`, which can concatenate two lists:

<oxcaml utop>
let combined_list = [1;2;3] @ [4;5;6]
</oxcaml>

It's important to remember that, unlike `::`, this is not a constant-time
operation. Concatenating two lists takes time proportional to the length of
the first list.

# Exercises

1. Write a function that takes a list of integers and returns a new list containing only
   the even elements:

   ```ocaml
   val evens_only : int list -> int list
   ```

   You should use the `List.filter` function:

   ```ocaml
   'a list -> f:('a -> bool) -> 'a list
   ```

   Like `List.map`, `List.filter` takes a labeled argument `~f` for the function it will
   apply to each element of this list. In this case, only the elements for which `~f`
   returns `true` are included in the returned list.

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)


   (* Tests: *)
   let () = assert (List.equal Int.equal (evens_only [1; 2; 3; 4; 5; 6]) [2; 4; 6])
   let () = assert (List.equal Int.equal (evens_only [7; 9; 11; 13; 15]) [])
   let () = assert (List.equal Int.equal (evens_only []) [])
   </oxcaml>

2. Write a function that takes a tuple of three elements and returns a list of those
   elements:

   ```ocaml
   val list_of_tuple : 'a * 'a * 'a -> 'a list
   ```

   Why is the type of the input tuple `'a * 'a * 'a` instead of `'a * 'b * 'c` as in
   `fst3`?[^1]

   [^1]: Because all elements of a list must be the same type.

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)


   (* Tests: *)
   let () = assert (List.equal Int.equal (list_of_tuple (1, 2, 3)) [1; 2; 3])
   let () = assert (List.equal Char.equal (list_of_tuple ('a', 'b', 'c')) ['a'; 'b'; 'c'])
   </oxcaml>

3. Write a function that takes a list of three-tuples and returns a list of the second
   element of each tuple:

   ```ocaml
   val all_snd3 : ('a * 'b * 'c) list -> 'b list
   ```

   Example:

   ```ocaml
   # all_snd3 [(1, "two", 3.0); (4, "five", 6.0); (7, "eight", 9.0)]
   - : string list = ["two"; "five"; "eight"]
   ```

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)


   (* Tests: *)
   let () = assert (List.equal Char.equal (all_snd3 [(1, 'a', 'A'); (2, 'b', 'B'); (3, 'c', 'C')]) ['a'; 'b'; 'c'])
   let () = assert (List.equal Bool.equal (all_snd3 [(1, true, false); (2, false, true)]) [true; false])
   let () = assert (List.equal Char.equal (all_snd3 []) [])
   </oxcaml>

Continue to the [next page](./tour-of-ocaml-03.md).
