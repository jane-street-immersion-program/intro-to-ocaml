<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

**A Note About Solutions**

At the start of each of these part 1 pages, we'll have the solutions to the exercises from
the previous page.  We'll sometimes have commentary about other features of OCaml that
could apply to the solutions.  We put exercises and solutions on separate pages to
encourage you to make a serious attempt at your own solution before looking at ours.

Make sure to ask a TA if you have any questions about an example solution!

## Solutions to the [Previous Exercises](./tour-of-ocaml-00.md#exercises)

<oxcaml data-oxcaml-run-trigger="manual-after-initial">
open Core

let min3 a b c = if a < b then (if a < c then a else c) else (if b < c then b else c)

let min3_float a b c =
  if Float.O.(a < b)
  then if Float.O.(a < c) then a else c
  else if Float.O.(b < c)
  then b
  else c
;;
</oxcaml>

# Type Inference

As the types we encounter get more complicated, you might ask yourself how OCaml is able
to figure them out, given that we didn't write down any explicit type information.

OCaml determines the type of an expression using a technique called
_type inference_, by which the type of an expression is inferred from the
available type information about the components of that expression.

As an example, let's walk through the process of inferring the type of
`sum_if_true` from earlier (copied here for convenience):

<oxcaml utop>
let sum_if_true test first second =
  (if test first then first else 0)
  + (if test second then second else 0)
</oxcaml>

1. OCaml requires that both branches of an `if` expression have the
   same type, so the expression

   `if test first then first else 0`

   requires that `first` must be the same type as `0`, and so `first` must be
   of type `int`. Similarly, from

   `if test second then second else 0`

   we can infer that `second` has type `int`.

2. `test` is passed `first` as an argument. Since `first` has type `int`, the
   input type of `test` must be `int`.

3. `test first` is used as the condition in an `if` expression, so the
   return type of `test` must be `bool`.

4. The fact that `+` returns `int` implies that the return value of
   `sum_if_true` must be int.

Together, that nails down the types of all the variables, which determines
the overall type of `sum_if_true`.

Over time, you'll build a rough intuition for how the OCaml inference engine
works, which makes it easier to reason through your programs. You can also
make it easier to understand the types of a given expression by adding
explicit type annotations. These annotations don't change the behavior of an
OCaml program, but they can serve as useful documentation, as well as catch
unintended type changes. They can also be helpful in figuring out why a given
piece of code fails to compile.

Here's an annotated version of `sum_if_true`:

<oxcaml utop>
let sum_if_true (test : int -> bool) (x : int) (y : int) : int =
  (if test x then x else 0)
  + (if test y then y else 0)
</oxcaml>

In the above, we've marked every argument to the function with its type, with
the final annotation indicating the type of the return value. Such type
annotations can be placed on any expression in an OCaml program.

# Inferring Generic Types

Sometimes, there isn't enough information to fully determine the concrete type of a given
value. Consider this function.

<oxcaml utop>
let first_if_true test x y =
  if test x then x else y
</oxcaml>

`first_if_true` takes as its arguments a function `test`, and two values,
`x` and `y`, where `x` is to be returned if `test x` evaluates to `true`, and
`y` otherwise. So what's the type of the `x` argument to `first_if_true`?
There are no obvious clues such as arithmetic operators or literals to narrow
it down. That makes it seem like `first_if_true` would work on values of any
type.

Indeed, if we look at the type returned by the toplevel, we see that rather than choose a
single concrete type, OCaml has introduced a _type parameter_ `'a` to express that the type
is generic. (You can tell it's a type parameter by the leading single quote mark.) In
particular, the type of the `test` argument is `('a -> bool)`, which means that `test` is
a one-argument function whose return value is `bool` and whose argument could be of any
type `'a`. But, whatever type `'a` is, it has to be the same as the type of the other two
arguments, `x` and `y`, and of the return value of `first_if_true`. This kind of
genericity is called _parametric polymorphism_ because it works by parameterizing the type
in question with a type parameter. It is very similar to generics in C# and Java.

Because the type of `first_if_true` is generic, we can write this:

<oxcaml utop>
let first_if_true test x y =
  if test x then x else y

let long_string s = String.length s > 6
let get_long_string = first_if_true long_string "short" "loooooong"
</oxcaml>

As well as this:

<oxcaml utop>
let first_if_true test x y =
  if test x then x else y

let big_number x = x > 3
let get_big_number = first_if_true big_number 4 3
</oxcaml>

Both `long_string` and `big_number` are functions, and each is passed to
`first_if_true` with two other arguments of the appropriate type (strings in
the first example, and integers in the second). But we can't mix and match
two different concrete types for `'a` in the same use of `first_if_true`:

<oxcaml utop>
let first_if_true test x y =
  if test x then x else y

let big_number x = x > 3;;
first_if_true big_number "short" "loooooong"
</oxcaml>

In this example, `big_number` requires that `'a` be instantiated as `int`,
whereas `"short"` and `"loooooong"` require that `'a` be instantiated as
`string`, and they can't both be right at the same time.

## Type Errors Versus Exceptions

There's a big difference in OCaml between errors that are caught at compile time and those
that are caught at runtime. It's better to catch errors as early as possible in the
development process, and compilation time is best of all.

Working in the toplevel somewhat obscures the difference between runtime and
compile-time errors, but that difference is still there. Generally, type
errors like this one:

<oxcaml utop>
let add_potato x = x + "potato"
</oxcaml>

are compile-time errors (because `+` requires that both its arguments be of
type `int`), whereas errors that can't be caught by the type system, like
division by zero, lead to runtime exceptions:

<oxcaml utop>
open Core

let is_a_multiple x y = x % y = 0
let check_8_and_2 = is_a_multiple 8 2
let check_8_and_0 = is_a_multiple 8 0
</oxcaml>

The distinction here is that type errors will stop you whether or not the
offending code is ever actually executed. Merely defining `add_potato` is an
error, whereas `is_a_multiple` only fails when it's called, and then, only
when it's called with an input that triggers the exception.

# Tuples

So far we've encountered a handful of basic types like `int`, `float`, and `string`, as
well as function types like `string -> int`. But we haven't yet talked about any data
structures. We'll start by looking at a particularly simple data structure, the tuple. A
tuple is an ordered collection of values that can each be of a different type. You can
create a tuple by joining values together with a comma.

<oxcaml utop>
let a_tuple = (3,"three")
let another_tuple = (3,"four",5.)
</oxcaml>

For the mathematically inclined, `*` is used in the type `t * s`
because that type corresponds to the set of all pairs containing one
value of type `t` and one of type `s`. In other words, it's the
_Cartesian product_ of the two types, which is why we use `*`, the
symbol for product.

You can extract the components of a tuple using OCaml's pattern-matching
syntax, as shown below:

<oxcaml utop>
let a_tuple = (3,"three")
let (x,y) = a_tuple
</oxcaml>

Here, the `(x,y)` on the left-hand side of the `let` binding is the pattern.
This pattern lets us mint the new variables `x` and `y`, each bound to
different components of the value being matched. These can now be used in
subsequent expressions:

<oxcaml utop>
let a_tuple = (3,"three")
let (x,y) = a_tuple
let use_x_and_y = x + String.length y
</oxcaml>

Note that the same syntax is used both for constructing and for pattern
matching on tuples.

Pattern matching can also show up in function arguments. Here's a function
for computing the distance between two points on the plane, where each point
is represented as a pair of `float`s. The pattern-matching syntax lets us get
at the values we need with a minimum of fuss:

<oxcaml utop>
open Core

let distance (x1,y1) (x2,y2) =
  Float.sqrt ((x1 -. x2) **. 2. +. (y1 -. y2) **. 2.)
</oxcaml>

The `**.` operator used above is for raising a floating-point number
to a power.

This is just a first taste of pattern matching. Pattern matching is a
pervasive tool in OCaml, and as you'll see, it has surprising power.

## Labeled Tuples

Ordinary tuples are positional, meaning the components are distinguished _purely_ by their position (whether they come first, second, third, etc.).
OCaml also supports _labeled_ tuples, where components are distinguished by name as well as position.
This can be especially useful when dealing with tuples that contain multiple values of the same type, as a way to make it much harder to mix them up.

For example, consider

<oxcaml utop>
let unlabeled_dimensions = 10, 20
let labeled_dimensions = ~width:10, ~height:20
</oxcaml>

Note that the syntax for labels is `~label:value`,
and that the labels are reflected in the type the toplevel prints out.
We can pattern match on labeled tuples in a similar fashion to unlabeled ones:

<oxcaml utop>
let labeled_dimensions = ~width:10, ~height:20
let ~width, ~height = labeled_dimensions
</oxcaml>

The compiler requires we use the correct labels in the correct order:

<oxcaml utop>
let labeled_dimensions = ~width:10, ~height:20
let ~x, ~y = labeled_dimensions
let ~height, ~width = labeled_dimensions
</oxcaml>

<oxcaml utop>
let labeled_dimensions = ~width:10, ~height:20
let ~height, ~width = labeled_dimensions
</oxcaml>

We can see the extra safety of labeled tuples by observing that the compiler happily lets us write a bug with the unlabeled version where we accidentally swap width and height:

<oxcaml utop>
let unlabeled_dimensions = 10, 20 (* width of 10, height of 20 *)
let height, width = unlabeled_dimensions
</oxcaml>

# Exercises

1. `fst` and `snd` are OCaml standard library functions that operate on pairs of values
   (i.e., 2-element tuples). The function `fst` returns the first component of a pair and
   `snd` returns the second component:

   ```ocaml
   # fst (3, 4);;
   - : int = 3
   # snd (3, 4);;
   - : int = 4
   ```

   Your task is to implement three functions:

   ```ocaml
   val fst3 : 'a * 'b * 'c -> 'a (* return the first element *)
   val snd3 : 'a * 'b * 'c -> 'b (* return the second element *)
   val trd3 : 'a * 'b * 'c -> 'c (* return the third element *)
   ```

   The editor below has test cases ready to go---add your three definitions above them
   and hit ***Run***.

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solutions here: *)


   (* Tests: *)
   let () = assert (fst3 (42, "world", 3.14) = 42)
   let () = assert (String.equal (snd3 (42, "world", 3.14)) "world")
   let () = assert (Float.equal (trd3 (42, "world", 3.14)) 3.14)
   </oxcaml>

2. Implement the `distance` function from above such that it takes two labeled tuples of type `x:float * y:float` instead of two unlabled ones.
   You'll still need to have different names for the two `x` values and the two `y` values, however, so you'll need to use the OCaml syntax for renaming a labeled item in a local scope: `~label:new_name`.
   In the context of our earlier dimensions example where the tuple had type `width:int * height:int`, this would look something like

   ```ocaml
   # let area (~width:w, ~height:h) =
       (* We've renamed [width] to [w] and [height] to [h] *)
       w * h
     ;;
   val area : (width:int * height:int) -> int = <fun>
   ```

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Add your solution here: *)


   (* Tests: *)
   let () = assert (Float.equal (distance (~x:0., ~y:0.) (~x:3., ~y:4.)) 5.0)
   let () = assert (Float.equal (distance (~x:5., ~y:7.) (~x:5., ~y:7.)) 0.0)
   let () = assert (Float.equal (distance (~x:(-1.), ~y:(-1.)) (~x:2., ~y:3.)) 5.0)
   </oxcaml>

Continue to the [next page](./tour-of-ocaml-02.md).
