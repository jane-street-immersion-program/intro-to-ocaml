<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

## Solutions to the [Previous Exercises](./tour-of-ocaml-04.md#exercises)

<oxcaml data-oxcaml-run-trigger="manual-after-initial">
open Core

let rec length xs =
  match xs with
  | [] -> 0
  | _ :: tl -> 1 + length tl
;;

let rec rev xs =
  match xs with
  | [] -> xs
  | hd :: tl -> (rev tl) @ [hd]
;;
</oxcaml>

# Tail Recursion

The only way to compute the length of an OCaml list is to walk the list from beginning to
end. As a result, computing the length of a list takes time linear in the size of the
list.

This seems simple enough, but when implemented in the straightfoward way shown above, this
approach runs into problems on very large lists:

```ocaml
# let identity x = x;;
val identity : 'a -> 'a = <fun>
# let make_list n = List.init n ~f:identity;;
val make_list : int -> int list = <fun>
# length (make_list 10);;
- : int = 10
# length (make_list 10_000_000);;
Stack overflow during evaluation (looping recursion?).
```

The preceding example creates lists using `List.init`, which takes an integer
`n` and a function `f` and creates a list of length `n`, where the data for
each element is created by calling `f` on the index of that element.

To understand where the error in the above example comes from, you need to
learn a bit more about how function calls work. Typically, a function call
needs some space to keep track of information associated with the call, such
as the arguments passed to the function, or the location of the code that
needs to start executing when the function call is complete. To allow for
nested function calls, this information is typically organized in a stack,
where a new _stack frame_ is allocated for each nested function call, and
then deallocated when the function call is complete.

And that's the problem with our call to `length`: it tried to allocate 10
million stack frames, which exhausted the available stack space. Happily,
there's a way around this problem. Consider the following alternative
implementation:

<oxcaml utop>
let rec length_plus_n l n =
  match l with
  | [] -> n
  | _ :: tl -> length_plus_n tl (n + 1)
;;

let length l = length_plus_n l 0
let result = length [1;2;3;4]
</oxcaml>

This implementation depends on a helper function, `length_plus_n`, that
computes the length of a given list plus a given `n`. In practice, `n` acts
as an accumulator in which the answer is built up, step by step. As a result,
we can do the additions along the way rather than doing them as we unwind the
nested sequence of function calls, as we did in our first implementation of
`length`.

The advantage of this approach is that the recursive call in `length_plus_n`
is a _tail call_. We'll explain more precisely what it means to be a tail
call shortly, but the reason it's important is that tail calls don't require
the allocation of a new stack frame, due to what is called the
_tail-call optimization_. A recursive function is said to be _tail recursive_
if all of its recursive calls are tail calls. `length_plus_n` is indeed tail
recursive, and as a result, `length` can take a long list as input without
blowing the stack:

```ocaml
# length (make_list 10_000_000);;
- : int = 10000000
```

So when is a call a tail call? Let's think about the situation where one
function (the _caller_) invokes another (the _callee_). The invocation is
considered a tail call when the caller doesn't do anything with the value
returned by the callee except to return it. The tail-call optimization makes
sense because, when a caller makes a tail call, the caller's stack frame need
never be used again, and so you don't need to keep it around. Thus, instead
of allocating a new stack frame for the callee, the compiler is free to reuse
the caller's stack frame.

Tail recursion is important for more than just lists. Ordinary non-tail
recursive calls are reasonable when dealing with data structures like binary
trees, where the depth of the tree is logarithmic in the size of your data.
But when dealing with situations where the depth of the sequence of nested
calls is on the order of the size of your data, tail recursion is usually the
right approach.

# Exercises

Using the example of `length_plus_n` as a guide, implement a tail-recursive version of
`rev`.

<oxcaml data-oxcaml-run-trigger="manual">
open Core

(* Add your solution here: *)


(* Tests: *)
let () = assert (List.equal Int.equal (rev []) [])
let () = assert (List.equal Int.equal (rev [1]) [1])
let () = assert (List.equal Int.equal (rev [1; 2; 3]) [3; 2; 1])
let big_list = List.init 10_000_000 ~f:Fn.id
let () = assert (List.equal Int.equal (rev big_list) (List.rev big_list))
</oxcaml>

Continue to the [next page](./tour-of-ocaml-06.md).
