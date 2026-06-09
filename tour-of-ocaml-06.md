<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

## Solutions to the [Previous Exercises](./tour-of-ocaml-05.md#exercises)

<oxcaml data-oxcaml-run-trigger="manual-after-initial">
open Core

let rec rev_helper xs acc =
  match xs with
  | [] -> acc
  | hd :: tl -> rev_helper tl (hd :: acc)
;;

let rev xs = rev_helper xs []
</oxcaml>

# Options

Another common data structure in OCaml is the _option_. An option is used to
express that a value might or might not be present. For
example:

<oxcaml utop>
let divide x y =
if y = 0 then None else Some (x / y)
</oxcaml>

The function `divide` either returns `None` if the divisor is zero, or
`Some` of the result of the division otherwise. `Some` and `None` are
constructors that let you build optional values, just as `::` and `[]` let
you build lists. You can think of an option as a specialized list that can
only have zero or one elements.

To examine the contents of an option, we use pattern matching, as we did with
tuples and lists. Let's see how this plays out in a small example. We'll
write a function that takes a filename, and returns a version of that
filename with the file extension (the part after the dot) downcased. We'll
base this on the function `String.rsplit2` to split the string based on the
rightmost period found in the string. Note that `String.rsplit2` has return
type `(string * string) option`, returning `None` when no character was found
to split on.

<oxcaml utop>
open Core

let downcase_extension filename =
  match String.rsplit2 filename ~on:'.' with
  | None -> filename
  | Some (base,ext) ->
    base ^ "." ^ String.lowercase ext
;;

let result = List.map ~f:downcase_extension
  [ "Hello_World.TXT"; "Hello_World.txt"; "Hello_World" ]
</oxcaml>

Note that we used the `^` operator for concatenating strings. The
concatenation operator is provided as part of the `Stdlib` module, which
is automatically opened in every OCaml program.

Options are important because they are the standard way in OCaml to encode a
value that might not be there; there's no such thing as a
`NullPointerException` in OCaml. This is different from most other languages,
including Java and C#, where most if not all data types are _nullable_,
meaning that, whatever their type is, any given value also contains the
possibility of being a null value. In such languages, null is lurking
everywhere.

In OCaml, however, missing values are explicit. A value of type
`string * string` always contains two well-defined values of type `string`.
If you want to allow, say, the first of those to be absent, then you need to
change the type to `string option * string`. This
explicitness allows the compiler to provide a great deal of help in making
sure you're correctly handling the possibility of missing data.

# Exercises

1. Write a function `lookup_char` that takes a list of integer-character tuples and an
   integer `n`. It should return an option containing the character associated with the
   given integer, or `None` if the integer is not found in the list.

   ```ocaml
   val lookup_char : (int * char) list -> int -> char option
   ```

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)


   (* Tests: *)
   let () = assert (Option.equal Char.equal (lookup_char [(1, 'a'); (2, 'b'); (3, 'c')] 2) (Some 'b'))
   let () = assert (Option.equal Char.equal (lookup_char [(1, 'a'); (2, 'b'); (3, 'c')] 4) None)
   let () = assert (Option.equal Char.equal (lookup_char [] 1) None)
   </oxcaml>

2. Write a recursive function `sum_options` that takes a list of integer options and
   calculates the sum of the values wrapped in `Some` constructor. If the list contains
   `None`, ignore it while calculating the sum.

   ```ocaml
   val sum_options : int option list -> int
   ```

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)


   (* Tests: *)
   let () = assert (sum_options [Some 1; None; Some 2; Some 3; None] = 6)
   let () = assert (sum_options [None; None] = 0)
   let () = assert (sum_options [Some 1; Some 2; Some 3;] = 6)
   let () = assert (sum_options [] = 0)
   </oxcaml>

3. Write a function `safe_sqrt` that takes an integer and returns an option. The function
   should return `Some` of the square root when the given integer is non-negative, and
   `None` otherwise. The square root can be computed using the `sqrt` function from the
   `Float` module.

   ```ocaml
   val safe_sqrt : int -> float option
   ```

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)


   (* Tests: *)
   let () = assert (Option.equal Float.equal (safe_sqrt 4) (Some 2.0))
   let () = assert (Option.equal Float.equal (safe_sqrt (-4)) None)
   </oxcaml>

   This is a good place to note a common compiler error you may
   encounter when writing code that chains a series of function calls together. Consider
   an attempt to implement a `sum_last_two` function similar to the `sum_first_two`
   function you wrote earlier using `List.rev` to reverse the list:

   <oxcaml utop>
   let sum_first_two xs =
      match xs with
      | x :: y :: _ -> [ x + y ]
      | _ -> []
   ;;

   let sum_last_two xs = sum_first_two List.rev xs
   </oxcaml>

   The compiler is complaining that we tried to call `sum_first_two` with two arguments
   when it takes only one. We need to use parentheses to
   clarify that we mean to call `List.rev` with `xs` and pass the result to `sum_first_two`:

   <oxcaml utop>
   let sum_first_two xs =
      match xs with
      | x :: y :: _ -> [ x + y ]
      | _ -> []
   ;;

   let sum_last_two xs = sum_first_two (List.rev xs)
   </oxcaml>

4. Write a function `calculate_area` that takes two float options, `length` and `width`,
   and returns an option containing the area of a rectangle. If either of the floats is
   missing (i.e., `None`), the function should return `None`.

   ```ocaml
   val calculate_area : float option -> float option -> float option
   ```

   You may find it useful for this exercise to match on multiple values:

   <oxcaml utop>
   let is_same_currency x y =
      match x, y with
      | "United States dollar", "USD"
      | "Hong Kong dollar", "HKD"
      | "Euro", "EUR"
      | "Sterling", "GBP" -> true
      | _ -> false
   </oxcaml>

   Syntactically, this match statement constructs the tuple `x, y` and then destructures
   it in each of the match arms. The compiler may optimize this away to avoid the extra
   allocation. This is one place where omitting the parentheses around a tuple is clear
   and idiomatic. Note that a single wildcard (`_`) can match the whole tuple.

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)


   (* Tests: *)
   let () = assert (Option.equal Float.equal (calculate_area (Some 3.0) (Some 4.0)) (Some 12.0))
   let () = assert (Option.equal Float.equal (calculate_area (Some 3.0) None) None)
   let () = assert (Option.equal Float.equal (calculate_area None (Some 4.0)) None)
   let () = assert (Option.equal Float.equal (calculate_area None None) None)
   </oxcaml>

Continue to the [next page](./tour-of-ocaml-07.md).
