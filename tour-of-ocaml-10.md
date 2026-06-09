<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

## Solutions to the [Previous Exercises](./tour-of-ocaml-09.md#exercises)

1.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let cumulative_sum arr =
     Array.iteri arr ~f:(fun i x -> if i = 0 then () else arr.(i) <- x + arr.(i - 1))
   ;;
   </oxcaml>

2.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   type person =
     { first_name : string
     ; last_name : string
     ; mutable age : int
     ; email : string option
     }

   let birthday person = person.age <- person.age + 1;;
   </oxcaml>

# Refs

We can create a single mutable value by using a `ref`. The `ref` type comes predefined in
the standard library, but there's nothing really special about it. It's just a record type
with a single mutable field called `contents`:

<oxcaml utop>
let x = { contents = 0 };;
x.contents <- x.contents + 1;;
let result = x
</oxcaml>

There are a handful of useful functions and operators defined for `ref`s to
make them more convenient to work with:

<oxcaml utop>
let x = ref 0;;     (* create a ref, i.e., { contents = 0 } *)
let contents = !x;; (* get the contents of a ref, i.e., x.contents *)
x := !x + 1;;       (* assignment, i.e., x.contents <- ... *)
let result = !x
</oxcaml>

There's nothing magical with these operators either. You can completely
reimplement the `ref` type and all of these operators in just a few lines of
code:

<oxcaml utop>
type 'a ref = { mutable contents : 'a }
let ref x = { contents = x }
let (!) r = r.contents
let (:=) r x = r.contents <- x
</oxcaml>

The `'a` before the `ref` indicates that the `ref` type is polymorphic, in the same way
that lists are polymorphic, meaning it can contain values of any type. The parentheses
around `!` and `:=` are needed because these are operators, rather than ordinary
functions.

Even though a `ref` is just another record type, it's important because it is
the standard way of simulating the traditional mutable variables you'll find
in most languages. For example, we can sum over the elements of a list
imperatively by calling `List.iter` to call a simple function on every
element of a list, using a `ref` to accumulate the results:

<oxcaml utop>
open Core

let sum list =
   let sum = ref 0 in
   List.iter list ~f:(fun x -> sum := !sum + x);
   !sum
</oxcaml>

This isn't the most idiomatic way to sum up a list, but it shows how you can
use a `ref` in place of a mutable variable.

# Exercises

1. Define another new version of the `person` record where the `age` field is a ref, and a new
   version of the [`birthday` function](./tour-of-ocaml-08.md#functional-updates) that mutates the
   ref instead of performing a functional update.
   Watch out for the precedence of `!`, as shown in the test.

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Define your [person] record (with [age] as a ref) and [birthday] function here: *)


   (* Tests: *)
   let hayao = { first_name = "Hayao"; last_name = "Miyazaki"; age = ref 82; email = Some "hmiyazaki@ghibli.com"}
   birthday hayao
   let () = assert (!(hayao.age) = 83)
   </oxcaml>

2. Write a function `map_ref` that takes a `'a ref` and a function `f : 'a -> 'b` as input
   and returns a new `'b ref` with the value of applying function `f` to the value of the
   input ref. The original ref should remain unchanged.

   ```ocaml
   map_ref : 'a ref -> f:('a -> 'b) -> 'b ref
   ```

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)


   (* Tests: *)
   let x_ref = ref 5
   let y_ref = map_ref x_ref ~f:(fun x -> x * 2)
   let () = assert (!x_ref = 5 && !y_ref = 10)
   </oxcaml>

Continue to the [next page](./tour-of-ocaml-11.md).
