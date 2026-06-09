<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

## Solutions to the [Previous Exercises](./tour-of-ocaml-03.md#exercises)

1.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let starts_with xs x ~equal =
     match xs with
     | first :: _ -> equal first x
     | [] -> false
   ;;
   </oxcaml>

2.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let sum_first_two xs =
     match xs with
     | first :: second :: rest -> (first + second) :: rest
     | _ :: [] | [] -> xs
   ;;
   </oxcaml>

In both the examples above, you'll notice we pass through the variable `xs` and then
immediately match on it. In OCaml, you can use the `function` keyword as an equivalent to
`fun x -> match x with ...` to make this more concise:

```ocaml
let some_fun x y = function
    | (pattern) -> ..
```

is equivalent to

```ocaml
let some_fun x y z =
    match z with
    | (pattern) -> ...
```

Note that the `function` keyword matches on the _last_ argument to the function.

You can also see in `sum_first_two` that a single match clause can contain multiple
patterns (called an _or pattern_).

# Recursive List Functions

Recursive functions, or functions that call themselves, are an important part of working
in OCaml or really any functional language. The typical approach to designing a recursive
function is to separate the logic into a set of _base cases_ that can be solved directly
and a set of _inductive cases_, where the function breaks the problem down into smaller
pieces and then calls itself to solve those smaller problems.

When writing recursive list functions, this separation between the base cases
and the inductive cases is often done using pattern matching. Here's a simple
example of a function that sums the elements of a list:

<oxcaml utop>
let rec sum l =
  match l with
  | [] -> 0                   (* base case *)
  | hd :: tl -> hd + sum tl   (* inductive case *)
;;

let result = sum [1;2;3]
</oxcaml>

Following the common OCaml idiom, we use `hd` to refer to the head of the
list and `tl` to refer to the tail. Note that we had to use the `rec` keyword
to allow `sum` to refer to itself. As you might imagine, the base case and
inductive case are different arms of the match.

Logically, you can think of the evaluation of a simple recursive function
like `sum` almost as if it were a mathematical equation whose meaning you
were unfolding step by step:

```ocaml
sum [1;2;3]
= 1 + sum [2;3]
= 1 + (2 + sum [3])
= 1 + (2 + (3 + sum []))
= 1 + (2 + (3 + 0))
= 1 + (2 + 3)
= 1 + 5
= 6
```

This suggests a reasonable if not entirely accurate mental model for
what OCaml is actually doing to evaluate a recursive function.

We can introduce more complicated list patterns as well. Here's a function
for removing sequential duplicates:

<oxcaml utop>
open Core

let rec remove_sequential_duplicates list =
  match list with
  | [] -> []
  | first :: second :: tl ->
    if first = second then
      remove_sequential_duplicates (second :: tl)
    else
      first :: remove_sequential_duplicates (second :: tl)
Lines 2-8, characters 5-61:
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
first::[]
</oxcaml>

Again, the first arm of the match is the base case, and the second is the
inductive case. Unfortunately, this code has a problem, as indicated by the
warning message. In particular, it doesn't handle one-element lists. We can
fix this warning by adding another case to the match:

<oxcaml utop>
open Core

let rec remove_sequential_duplicates list =
  match list with
  | [] -> []
  | [x] -> [x]
  | first :: second :: tl ->
    if first = second then
      remove_sequential_duplicates (second :: tl)
    else
      first :: remove_sequential_duplicates (second :: tl)
;;

let deduped = remove_sequential_duplicates [1;1;2;3;3;4;4;1;1;1]
</oxcaml>

Note that this code used another variant of the list pattern, `[x]`, to
match a list with a single element. We can do this to match a list with any
fixed number of elements; for example, `[x;y;z]` will match any list with
exactly three elements and will bind those elements to the variables
`x`, `y`, and `z`.

In the last few examples, our list processing code involved a lot of
recursive functions. In practice, this isn't usually necessary. Most of the
time, you'll find yourself happy to use the iteration functions found in the
`List` module. But it's good to know how to use recursion for when you need
to iterate in a new way.

# Exercises

To practice recursively matching on lists, reimplement the built-in `List.length` and
`List.rev` functions for getting the length of and reversing a list, respectively:

```ocaml
val length : 'a list -> int
val rev : 'a list -> 'a list
```

<oxcaml data-oxcaml-run-trigger="manual">
open Core

(* Add your solutions here: *)


(* Tests: *)
let () = assert (length [] = 0)
let () = assert (length [1] = 1)
let () = assert (length [1; 2; 3] = 3)

let () = assert (List.equal Int.equal (rev []) [])
let () = assert (List.equal Int.equal (rev [1]) [1])
let () = assert (List.equal Int.equal (rev [1; 2; 3]) [3; 2; 1])
</oxcaml>

Continue to the [next page](./tour-of-ocaml-05.md).
