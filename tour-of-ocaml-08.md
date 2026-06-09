<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

## Solutions to the [Previous Exercises](./tour-of-ocaml-07.md#exercises)

1.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   type card_value =
     | Ace
     | King
     | Queen
     | Jack
     | Number of int

   let straight = [Number 9; Number 10; Jack; Queen; King]
   </oxcaml>

2.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   type point2d = { x : float; y : float }
   type circle_desc  = { center: point2d; radius: float }
   type rect_desc    = { lower_left: point2d; width: float; height: float }
   type segment_desc = { endpoint1: point2d; endpoint2: point2d }
   type scene_element =
     | Circle  of circle_desc
     | Rect    of rect_desc
     | Segment of segment_desc

   let element_area element =
     match element with
     | Circle { radius; _ } -> Some (Float.pi *. (radius **. 2.0))
     | Rect { width; height; _ } -> Some (width *. height)
     | Segment _ -> None
   ;;
   </oxcaml>

3.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   type person =
     { first_name : string
     ; last_name : string
     ; age : int
     ; email : string option
     }

   let napoleon =
     { first_name = "Napoleon"; last_name = "Bonaparte"; age = 51; email = None }
   ;;

   let janelle =
     { first_name = "Janelle"
     ; last_name = "Monáe"
     ; age = 37
     ; email = Some "janelle@gmail.com"
     }
   ;;

   let get_email ~first_name ~last_name ~people =
     match
       List.find people ~f:(fun person ->
         String.equal person.first_name first_name && String.equal person.last_name last_name)
     with
     | Some { email; _ } -> email
     | None -> None
   ;;
   </oxcaml>

<!-- CR-someday bwiedenbeck: it's sad how we have to keep re-defining [type person]. We
should re-visit this once the oxcaml playground gives us a way to hide setup code. -->
4.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   type pet =
     | Dog of string
     | Cat of string
     | Fish of string

   type person =
     { first_name : string
     ; last_name : string
     ; age : int
     ; email : string option
     ; favorite_pet : pet
     }

   let napoleon =
     { first_name = "Napoleon"
     ; last_name = "Bonaparte"
     ; age = 51
     ; email = None
     ; favorite_pet = Dog "Newfoundland"
     }
   ;;

   let janelle =
     { first_name = "Janelle"
     ; last_name = "Monáe"
     ; age = 37
     ; email = Some "janelle@gmail.com"
     ; favorite_pet = Cat "Siamese"
     }
   ;;

   let describe_favorite_pet { first_name; last_name; favorite_pet; _ } =
     match favorite_pet with
     | Dog breed -> [%string "%{first_name} %{last_name}'s favorite pet is a %{breed} dog"]
     | Cat breed -> [%string "%{first_name} %{last_name}'s favorite pet is a %{breed} cat"]
     | Fish species ->
       [%string "%{first_name} %{last_name}'s favorite pet is a %{species} fish"]
   ;;
   </oxcaml>

# Functional Updates

Fairly often, you will find yourself wanting to create a new record that differs from an
existing record in only a subset of the fields. For example, we might want a `birthday`
function that increases a `person`'s age by 1:

<oxcaml utop>
type person =
  { first_name : string
  ; last_name : string
  ; age : int
  ; email : string option
  }

let birthday person =
  { first_name = person.first_name
  ; last_name = person.last_name
  ; age = person.age + 1
  ; email = person.email
  }
</oxcaml>

This function performs a _functional update_ since it does not modify the original, but
instead returns a new record with a new `age` value. We can rewrite `birthday` a little
nicer by destructuring the argument, and taking advantage of field punning (e.g., instead
of writing `first_name = first_name` we can just write `first_name`, because the names
match exactly):

<oxcaml utop>
type person =
  { first_name : string
  ; last_name : string
  ; age : int
  ; email : string option
  }

let birthday_with_sugar { age; first_name; last_name; email } =
  { age = age + 1
  ; first_name
  ; last_name
  ; email
  }
</oxcaml>

But there's even more syntactic sugar available: the OCaml `with` keyword:

<oxcaml utop>
type person =
  { first_name : string
  ; last_name : string
  ; age : int
  ; email : string option
  }

let birthday_with_even_more_sugar t = { t with age = t.age + 1 }
</oxcaml>

# Nesting lets with `let` and `in`

A `let` paired with an `in` can be used to introduce a new binding within any local scope, including a function body.
The `in` marks the beginning of the scope within which the new variable can be used.
Thus, we could write:

<oxcaml utop>
let result =
  let z = 7 in
  z + z
</oxcaml>

Note that the scope of the `let` binding is terminated by the
double-semicolon, so the value of `z` is no longer available:

<oxcaml utop>
let result =
  let z = 7 in
  z + z
let x = z
</oxcaml>

We can also have multiple `let` bindings in a row, each one adding a
new variable binding to what came before:

<oxcaml utop>
let result =
  let x = 7 in
  let y = x * x in
  x + y
</oxcaml>

This kind of nested `let` binding is a common way of building up a complex
expression, with each `let` naming some component, before combining them in
one final expression.

# Exercises

First a little practice reading type signatures. For each of these `List` functions, try
and guess what they do just based on the type. Then see if you guessed correctly.

```ocaml
List.mapi : 'a list -> f:(int -> 'a -> 'b) -> 'b list
List.filter_map : 'a list -> f:('a -> 'b option) -> 'b list
List.filter_opt : 'a option list -> 'a list
List.zip_exn : 'a list -> 'b list -> ('a * 'b) list
List.take : 'a list -> int -> 'a list
List.concat : 'a list list -> 'a list
```

~~~spoiler {title: "Answers"}
- `mapi` is like `map`. Additionally, it passes in the index of each element as the first
  argument to the mapped function.
- `filter_map t ~f` applies `f` to every `x` in `t`. The result contains every `y` for
  which `f x` returns `Some y`.
- `filter_opt l` is the sublist of `l` containing only elements which are `Some e`. In
  other words, `filter_opt l = filter_map ~f:Fn.id l` (`Fn.id` is the identity function in
  `Core`, equivalent to `fun x -> x`).
- `zip_exn` transforms a pair of lists into a list of pairs: `zip_exn [a1; ...; an] [b1; ...; bn]`
  is `[(a1,b1); ...; (an,bn)]`. Raises an exception if the lists are different lengths.
- `take l n` returns the first `n` elements of `l`, or all of `l` if `n > length l`. `take
  l n = fst (split_n l n)`.
- `concat` concatenates a nested list. The elements of the inner lists are concatenated
  together in order to give the result.
~~~

Write a function `interleave` that takes two lists, `list1` and `list2`, and returns a
single list with elements of `list1` and `list2` interleaved. Assume that input lists have
equal length.

**Hint**: Use three of the `List` functions we've seen. Break up the steps using a sequence of
`let` bindings.

```ocaml
val interleave : 'a list -> 'a list -> 'a list
```

<oxcaml data-oxcaml-run-trigger="manual">
open Core

(* Add your solution here: *)

(* Test the basic functionality *)
let test_interleave_1 () =
  let list1 = [1; 3; 5] in
  let list2 = [2; 4; 6] in
  let expected = [1; 2; 3; 4; 5; 6] in
  let result = interleave list1 list2 in
  assert (List.equal Int.equal result expected)
;;

test_interleave_1 ()

(* Test with different values *)
let test_interleave_2 () =
  let list1 = ['a'; 'c'; 'e'] in
  let list2 = ['b'; 'd'; 'f'] in
  let expected = ['a'; 'b'; 'c'; 'd'; 'e'; 'f'] in
  let result = interleave list1 list2 in
  assert (List.equal Char.equal result expected)
;;

test_interleave_2 ()

(* Test with empty lists *)
let test_interleave_3 () =
  let list1 = [] in
  let list2 = [] in
  let expected = [] in
  let result = interleave list1 list2 in
  assert (List.equal Int.equal result expected)
;;

test_interleave_3 ()

(* Test with single-element lists *)
let test_interleave_4 () =
  let list1 = [7] in
  let list2 = [8] in
  let expected = [7; 8] in
  let result = interleave list1 list2 in
  assert (List.equal Int.equal result expected)
;;

test_interleave_4 ()

(* Test with repetitive values *)
let test_interleave_5 () =
  let list1 = [1; 1; 1] in
  let list2 = [2; 2; 2] in
  let expected = [1; 2; 1; 2; 1; 2] in
  let result = interleave list1 list2 in
  assert (List.equal Int.equal result expected)
;;

test_interleave_5 ()

(* Test with reverse-indexing values *)
let test_interleave_6 () =
  let list1 = [5; 3; 1] in
  let list2 = [6; 4; 2] in
  let expected = [5; 6; 3; 4; 1; 2] in
  let result = interleave list1 list2 in
  assert (List.equal Int.equal result expected)
;;

test_interleave_6 ()
</oxcaml>

Continue to the [next page](./tour-of-ocaml-09.md).
