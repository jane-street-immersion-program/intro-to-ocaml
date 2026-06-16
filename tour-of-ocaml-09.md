<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

## Solutions to the [Previous Exercises](./tour-of-ocaml-08.md#exercises)

<oxcaml data-oxcaml-run-trigger="manual-after-initial">
open Core

let interleave list1 list2 =
  let zipped = List.zip_exn list1 list2 in
  let sublists = List.map zipped ~f:(fun (x, y) -> [ x; y ]) in
  List.concat sublists
;;
</oxcaml>

When you have a sequence of operations like the above, the pipe operator `|>` can simplify
your code. It takes the result of one function and passes it as the argument to the next,
chaining calls together in a short expression.

<oxcaml utop>
let (|>) x f = f x
</oxcaml>

This is an example of defining an _infix operator_ in OCaml (i.e, an operator that can
appear between its arguments). A function of two arguments can be used as an infix
operator if its name consists of [infix
symbols](https://v2.ocaml.org/manual/lex.html#infix-symbol).

Here's the `interleave` rewritten using `|>`:

<oxcaml utop>
open Core

let interleave list1 list2 =
  List.zip_exn list1 list2
  |> List.map ~f:(fun (x, y) -> [x; y])
  |> List.concat
</oxcaml>

One of the uses of labeled arguments is to facilitate this kind of pipelining. Partially
applying `List.map` with `~f` gives us a one-argument function that can take the list
returned by a previous function in the chain.

The pipe operator may sometimes improve conciseness and readability, but it can also
create confusing and hard to follow code. A helpful tip is to use the pipe operator when
an intermediate variable name doesn't provide extra information about the operation, as in
the example above.

**Writing functional code should be your default**

Before we leave the world of pure functions and immutable data to introduce some of
OCaml's imperative programming features, it's worth emphasizing that imperative
programming tends to be the exception rather than the rule at Jane Street. There are of
course situations where mutability is quite useful or even necessary. In most contexts,
however, you should prefer a functional approach over an imperative one.

# Imperative Programming

The code we've written so far has been almost entirely _pure_ or
_functional_, which roughly speaking means that the code in question doesn't
modify variables or values as part of its execution. Indeed, almost all of
the data structures we've encountered are _immutable_, meaning there's no way
in the language to modify them at all. This is a quite different style from
_imperative_ programming, where computations are structured as sequences of
instructions that operate by making modifications to the state of the
program.

Functional code is the default in OCaml, with variable bindings and most data
structures being immutable. But OCaml also has excellent support for
imperative programming, including mutable data structures like arrays and
hash tables, and control-flow constructs like `for` and `while` loops.

## Arrays

Perhaps the simplest mutable data structure in OCaml is the array. Arrays in
OCaml are very similar to arrays in other languages like C: indexing starts
at 0, and accessing or modifying an array element is a constant-time
operation. Arrays are more compact in terms of memory utilization than most
other data structures in OCaml, including lists. Here's an example:

<oxcaml utop>
let numbers = [| 1; 2; 3; 4 |];;
numbers.(2) <- 4;;
let result = numbers
</oxcaml>

The `.(i)` syntax is used to refer to an element of an array, and the
`<-` syntax is for modification. Because the elements of the array are
counted starting at zero, element `numbers.(2)` is the third element.

The `unit` type that we see in the preceding code is interesting in that it
has only one possible value, written `()`. This means that a value of type
`unit` doesn't convey any information, and so is generally used as a
placeholder. Thus, we use `unit` for the return value of an operation like
setting a mutable field that communicates by side effect rather than by
returning a value. It's also used as the argument to functions that don't
require an input value. This is similar to the role that `void` plays in
languages like C and Java.

## Mutable Record Fields

The array is an important mutable data structure, but it's not the only one.
Records, which are immutable by default, can have some of their fields
explicitly declared as mutable. Here's an example of a mutable data structure
for storing a running statistical summary of a collection of
numbers.

<oxcaml utop>
type running_sum =
  { mutable sum: float;
    mutable sum_sq: float; (* sum of squares *)
    mutable samples: int;
  }
</oxcaml>

The fields in `running_sum` are designed to be easy to extend incrementally,
and sufficient to compute means and standard deviations, as shown in the
following example.

<oxcaml utop>
open Core

type running_sum =
  { mutable sum: float;
    mutable sum_sq: float; (* sum of squares *)
    mutable samples: int;
  }

let mean rsum = rsum.sum /. Float.of_int rsum.samples
let stdev rsum =
  Float.sqrt
    (rsum.sum_sq /. Float.of_int rsum.samples -. mean rsum **. 2.)
</oxcaml>

We also need functions to create and update `running_sum`s:

<oxcaml utop>
open Core

type running_sum =
  { mutable sum: float;
    mutable sum_sq: float; (* sum of squares *)
    mutable samples: int;
  }

let create () = { sum = 0.; sum_sq = 0.; samples = 0 }
let update rsum x =
  rsum.samples <- rsum.samples + 1;
  rsum.sum     <- rsum.sum     +. x;
  rsum.sum_sq  <- rsum.sum_sq  +. x *. x
</oxcaml>

`create` returns a `running_sum` corresponding to the empty set, and
`update rsum x` changes `rsum` to reflect the addition of `x` to its set of
samples by updating the number of samples, the sum, and the sum of squares.

Note the use of single semicolons to sequence operations that return `unit`. When we were
working purely functionally, this wasn't necessary, but you start needing it
when you're writing imperative code.

Here's an example of `create` and `update` in action. Note that this code
uses `List.iter`, which calls the function `~f` on each element of the
provided list:

<oxcaml utop>
open Core

type running_sum =
  { mutable sum: float;
    mutable sum_sq: float; (* sum of squares *)
    mutable samples: int;
  }

let create () = { sum = 0.; sum_sq = 0.; samples = 0 }

let update rsum x =
  rsum.samples <- rsum.samples + 1;
  rsum.sum     <- rsum.sum     +. x;
  rsum.sum_sq  <- rsum.sum_sq  +. x *. x

let mean rsum = rsum.sum /. Float.of_int rsum.samples

let stdev rsum =
  Float.sqrt
    (rsum.sum_sq /. Float.of_int rsum.samples
    -. (rsum.sum /. Float.of_int rsum.samples) **. 2.)

let rsum = create ();;

List.iter [1.;3.;2.;-7.;4.;5.] ~f:(fun x -> update rsum x);;
let mean_result = mean rsum
let stdev_result = stdev rsum
</oxcaml>

Be aware: the preceding algorithm is numerically naive and has poor
precision in the presence of many values that cancel each other
out. This Wikipedia [article on algorithms for calculating
variance](http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance)
provides more details.

# Exercises

1. Write a function that takes an array of integers and modifies it in-place such that each
   index contains the sum of the array elements up to that point.

   ```ocaml
   val cumulative_sum : int array -> unit
   ```

   Since the function modifies the array and doesn't produce a new value, its return type is
   `unit`.

   To iterate over the indices of an array, you can use:

   ```ocaml
   Array.iteri : 'a array -> f:(int -> 'a -> unit) -> unit
   ```

   where `f` is a two-argument function of an index and the corresponding element.

   Note that you can use `()` for an expression of type `unit`:

   <oxcaml utop>
   open Core

   let print_if_odd x = if x % 2 = 0 then () else Stdio.printf "%d\n" x
   </oxcaml>

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)


   (* Tests: *)
   let input_array = [||] ;;
   cumulative_sum input_array
   let () = assert (Array.equal Int.equal input_array [||])
   let input_array = [|1|] ;;
   cumulative_sum input_array
   let () = assert (Array.equal Int.equal input_array [|1|])
   let input_array = [|1; 2; 3; 4|] ;;
   cumulative_sum input_array
   let () = assert (Array.equal Int.equal input_array [|1; 3; 6; 10|])
   </oxcaml>

2. Define a new version of the `person` record where the `age` field is mutable, and a new
   version of the [`birthday` function](./tour-of-ocaml-08.md#functional-updates) that mutates the
   `age` field instead of performing a functional update.

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Define your mutable [person] record and [birthday] function here: *)


   (* Tests: *)
   let ulysses = { first_name = "Ulysses"; last_name = "Grant"; age = 50; email = None} ;;
   birthday ulysses
   let () = assert (ulysses.age = 51)
   </oxcaml>

Continue to the [next page](./tour-of-ocaml-10.md).
