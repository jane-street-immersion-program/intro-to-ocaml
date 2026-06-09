<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

## Solutions to the [Previous Exercises](./tour-of-ocaml-06.md#exercises)

1.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let rec lookup_char pairs i =
     match pairs with
     | [] -> None
     | (j, c) :: tl -> if j = i then Some c else lookup_char tl i
   ;;
   </oxcaml>

2.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let rec sum_options = function
     | [] -> 0
     | Some x :: tl -> x + sum_options tl
     | None :: tl -> sum_options tl
   ;;

   let rec sum_options_helper acc = function
     | [] -> acc
     | Some x :: tl -> sum_options_helper (acc + x) tl
     | None :: tl -> sum_options_helper acc tl
   ;;

   let sum_options xs = sum_options_helper 0 xs
   </oxcaml>

3.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let safe_sqrt x = if x < 0 then None else Some (Float.sqrt (float x))
   </oxcaml>

4.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let calculate_area height width =
     match height, width with
     | Some h, Some w -> Some (h *. w)
     | _ -> None
   ;;
   </oxcaml>

# Records and Variants

So far, we've only looked at data structures that were predefined in the
language, like lists and tuples. But OCaml also allows us to define new data
types. Here's a toy example of a data type representing a point in
two-dimensional space:

<oxcaml utop>
type point2d = { x : float; y : float }
</oxcaml>

`point2d` is a *record* type, which you can think of as a tuple where the
individual fields are named, rather than being defined positionally. Record
types are easy enough to construct:

<oxcaml utop>
type point2d = { x : float; y : float }
let p = { x = 3.; y = -4. }
</oxcaml>

And we can get access to the contents of these types using pattern matching:

<oxcaml utop>
open Core

type point2d = { x : float; y : float }

let magnitude { x = x_pos; y = y_pos } =
  Float.sqrt (x_pos **. 2. +. y_pos **. 2.)
</oxcaml>

The pattern match here binds the variable `x_pos` to the value contained in
the `x` field, and the variable `y_pos` to the value in the `y` field.

We can write this more tersely using what's called *field punning*. In
particular, when the name of the field and the name of the variable it is
bound to coincide, we don't have to write them both down. Using this, our
magnitude function can be rewritten as follows:

<oxcaml utop>
open Core

type point2d = { x : float; y : float }

let magnitude { x; y } = Float.sqrt (x **. 2. +. y **. 2.)
</oxcaml>

Alternatively, we can use dot notation for accessing record fields:

<oxcaml utop>
open Core

type point2d = { x : float; y : float }

let magnitude { x; y } = Float.sqrt (x **. 2. +. y **. 2.)

let distance v1 v2 =
  magnitude { x = v1.x -. v2.x; y = v1.y -. v2.y }
</oxcaml>

And we can of course include our newly defined types as components in larger
types. Here, for example, are some types for modeling different geometric
objects that contain values of type `point2d`:

<oxcaml utop>
type point2d = { x : float; y : float }
type circle_desc = { center: point2d; radius: float }
type rect_desc = { lower_left: point2d; width: float; height: float }
type segment_desc = { endpoint1: point2d; endpoint2: point2d }
</oxcaml>

Now, imagine that you want to combine multiple objects of these types
together as a description of a multi-object scene. You need some unified way
of representing these objects together in a single type. *Variant*
types let you do just that:



<oxcaml utop>
type point2d = { x : float; y : float }
type circle_desc = { center: point2d; radius: float }
type rect_desc = { lower_left: point2d; width: float; height: float }
type segment_desc = { endpoint1: point2d; endpoint2: point2d }

type scene_element =
  | Circle of circle_desc
  | Rect of rect_desc
  | Segment of segment_desc
</oxcaml>

The `|` character separates the different cases of the variant (the first
`|` is optional), and each case has a capitalized tag, like `Circle`,
`Rect` or `Segment`, to distinguish that case from the others. Tags are also called a constructors, since you use them to construct values of the variant type. They may optionally have a sequence of fields, where each field has a specified type. In this example, each tag has a field of the associated record type.

You might see variants that don't have fields:

<oxcaml utop>
type color =
  | Red
  | Green
  | Blue
</oxcaml>

or where some tags have fields and some don't:

<oxcaml utop>
type card_value =
  | Ace
  | King
  | Queen
  | Jack
  | Number of int
</oxcaml>

or where there's just one tag (usually in situations where the intention is to add more
later):

<oxcaml utop>
type services =
  | Prototype
</oxcaml>

Here's how we might write a function for testing whether a point is in
the interior of some element of a list of `scene_element`s.  Note that
there are two `let` bindings in a row without a double semicolon
between them. That's because the double semicolon is required only to
tell the toplevel to process the input, not to separate two declarations

<oxcaml utop>
open Core

type point2d = { x : float; y : float }
type circle_desc  = { center: point2d; radius: float }
type rect_desc    = { lower_left: point2d; width: float; height: float }
type segment_desc = { endpoint1: point2d; endpoint2: point2d }
type scene_element =
  | Circle  of circle_desc
  | Rect    of rect_desc
  | Segment of segment_desc

let magnitude { x; y } = Float.sqrt (x **. 2. +. y **. 2.)
let distance v1 v2 =
  magnitude { x = v1.x -. v2.x; y = v1.y -. v2.y }
;;

let is_inside_scene_element point scene_element =
  match scene_element with
  | Circle { center; radius } ->
    Float.O.(distance center point < radius)
  | Rect { lower_left; width; height } ->
    Float.O.(point.x > lower_left.x) && Float.O.(point.x < lower_left.x + width)
    && Float.O.(point.y > lower_left.y) && Float.O.(point.y < lower_left.y + height)
  | Segment _ -> false
;;


let is_inside_scene point scene =
  List.exists scene
    ~f:(fun el -> is_inside_scene_element point el)
;;

let inside_test1 = is_inside_scene {x=3.;y=7.}
  [ Circle {center = {x=4.;y= 4.}; radius = 0.5 } ]
;;

let inside_test2 = is_inside_scene {x=3.;y=7.}
  [ Circle {center = {x=4.;y= 4.}; radius = 5.0 } ]
;;
</oxcaml>

You might at this point notice that the use of `match` here is reminiscent of
how we used `match` with `option` and `list`. This is no accident: `option`
and `list` are just examples of variant types that are important enough to be
defined in the standard library (and in the case of lists, to have some
special syntax).

We also made our first use of an *anonymous function* in the call to
`List.exists`. Anonymous functions are declared using the `fun` keyword, and
don't need to be explicitly named. Such functions are common in OCaml,
particularly when using iteration functions like `List.exists`.

The purpose of `List.exists` is to check if there are any elements of the
list in question for which the provided function evaluates to `true`. In this
case, we're using `List.exists` to check if there is a scene element within
which our point resides.

We could use an anonymous function to implement the `evens_only` function you wrote earlier to avoid having to define a separate `even` function:

<oxcaml utop>
open Core

let evens_only xs = List.filter xs ~f:(fun x -> x % 2 = 0)
</oxcaml>

## `Core` and Polymorphic Comparison

One other thing to notice was the fact that we used `Float.O` in the
definition of `is_inside_scene_element`. That allowed us to use the simple,
un-dotted `+` operator, but more importantly it brought the float
comparison operators into scope. When using `Core`, the default comparison
operators work only on integers, and you need to explicitly choose other
comparison operators when you want them. OCaml also offers a special set of
*polymorphic comparison operators* that can work on almost any type, but
those are considered to be problematic, and so are hidden by default by
`Core`. You can read more about polymorphic compare
[here](https://dev.realworldocaml.org/lists-and-patterns.html#polymorphic-compare).

# Exercises

1. Construct a list representing a five-card straight (five cards with consecutive values)
   using the `card_value` variant type.

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   type card_value =
     | Ace
     | King
     | Queen
     | Jack
     | Number of int

   (* Define your five-card straight here: *)
   </oxcaml>

2. Write a function to compute the area of a `scene_element`:

   ```ocaml
   val element_area : scene_element -> float option
   ```

   For elements that don't have an area (i.e., `Segment`s), the function should return
   `None`.  When pattern matching on a record, you can match on the fields you care about
   and use a `_` to ignore the rest:

   ```ocaml
   match element with
   | Circle { radius; _ } -> (* we don't need the center field, so we ignore it in the match *)
   ```

   You can also give fields an alias when pattern matching on a record, and ignore
   specific fields by aliasing them to `_`:

   ```ocaml
   match element with
   | Circle { radius = r; center = _ } -> (* we make [r] as an alias for [radius] and ignore [center] *)
   ```

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   type point2d = { x : float; y : float }
   type circle_desc  = { center: point2d; radius: float }
   type rect_desc    = { lower_left: point2d; width: float; height: float }
   type segment_desc = { endpoint1: point2d; endpoint2: point2d }
   type scene_element =
     | Circle  of circle_desc
     | Rect    of rect_desc
     | Segment of segment_desc

   (* Add your solution here: *)


   (* Helper for comparing floats: *)
   let close_enough a b =
     let epsilon = 1e-6 in
     Float.O.(abs (a -. b) < epsilon)
   ;;

   (* Tests: *)
   let circle1 = Circle { center = { x = 2.; y = 3. }; radius = 3. }
   let circle2 = Circle { center = { x = 5.; y = -4. }; radius = 0. }
   let circle3 = Circle { center = { x = -2.; y = 1. }; radius = 2.5 }

   let () = assert (close_enough (Option.value_exn (element_area circle1)) (3. *. Float.pi *. 3.))
   let () = assert (close_enough (Option.value_exn (element_area circle2)) 0.)
   let () = assert (close_enough (Option.value_exn (element_area circle3)) (2.5 *. Float.pi *. 2.5))

   let rect1 = Rect { lower_left = { x = 1.; y = 2. }; width = 4.; height = 3. }
   let rect2 = Rect { lower_left = { x = 0.; y = 0. }; width = 0.; height = 0. }
   let rect3 = Rect { lower_left = { x = -1.; y = -1. }; width = 2.; height = 2. }

   let () = assert (close_enough (Option.value_exn (element_area rect1)) 12.)
   let () = assert (close_enough (Option.value_exn (element_area rect2)) 0.)
   let () = assert (close_enough (Option.value_exn (element_area rect3)) 4.)

   let segment1 = Segment { endpoint1 = { x = 1.; y = 1. }; endpoint2 = { x = 3.; y = 4. }; }
   let segment2 = Segment { endpoint1 = { x = 5.; y = 7. }; endpoint2 = { x = 8.; y = 10. }; }
   let segment3 = Segment { endpoint1 = { x = 0.; y = 0. }; endpoint2 = { x = 0.; y = 0. }; }

   let () = assert (Option.is_none (element_area segment1))
   let () = assert (Option.is_none (element_area segment2))
   let () = assert (Option.is_none (element_area segment3))
   </oxcaml>

3. Now we'll define a `person` record type, build two instances of it,
   and write a `get_email` function over a list of people.

   Start by defining `person` with the following fields:

   1. `first_name` of type `string`
   2. `last_name` of type `string`
   3. `age` of type `int`
   4. `email` of type `string option`

   Then create two instances of `person`, one for Napoleon Bonaparte and one for Janelle
   Monáe (yes, OCaml strings can contain Unicode characters). Naturally, Janelle should
   have the email `"janelle@gmail.com"`, and Napoleon should not have an email.

   Finally, define `get_email`, which takes a first name, a last name, and a list of
   people, searches for the person in the list matching the first and last name, and
   returns their email address (if available):

   ```ocaml
   val get_email : first_name:string -> last_name:string -> people:person list -> string option
   ```

   This is a good opportunity to try out the `List.find` function (`'a list -> f:('a ->
   bool) -> 'a option`) and practice creating an anonymous function.

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Define [person] here, along with the [napoleon] and [janelle] instances: *)


   (* Add your [get_email] definition here: *)


   (* Tests: *)
   let people = [napoleon; janelle];;
   let () = assert (Option.equal String.equal (get_email ~first_name:"Janelle" ~last_name:"Monáe" ~people) (Some "janelle@gmail.com"))
   let () = assert (Option.equal String.equal (get_email ~first_name:"Napoleon" ~last_name:"Bonaparte" ~people) None)
   let () = assert (Option.equal String.equal (get_email ~first_name:"Charlie" ~last_name:"Brown" ~people) None)
   let () = assert (Option.equal String.equal (get_email ~first_name:"Janelle" ~last_name:"Bonaparte" ~people) None)
   let () = assert (Option.equal String.equal (get_email ~first_name:"Napoleon" ~last_name:"Monáe" ~people) None)
   let () = assert (Option.equal String.equal (get_email ~first_name:"Janelle" ~last_name:"Monáe" ~people:[]) None)
   let () = assert (Option.equal String.equal (get_email ~first_name:"John" ~last_name:"Doe" ~people:[]) None)
   </oxcaml>

4. Now we'll extend the previous exercise: introduce a `pet` variant, give every
   `person` a favorite pet, and write a function that describes it.

   Start by defining a `pet` variant type with the following tags:

   1. `Dog` with a `string` field (representing the breed)
   2. `Cat` with a `string` field (representing the breed)
   3. `Fish` with a `string` field (representing the species)

   Then copy your `person` record type from above and extend it to include a field
   `favorite_pet` of type `pet`, and update Napoleon and Janelle to have one. Napoleon's
   favorite is a Newfoundland dog[^1] and Janelle's favorite is a Siamese cat[^2].
[^1]: A Newfoundland once [saved Napoleon from
      drowning](https://en.wikipedia.org/wiki/Newfoundland_dog#Water_rescue)
[^2]: To the best of our knowledge, Janelle does not have any traditional, organic household pets

   Finally, write a function `describe_favorite_pet` that takes a `person` and returns a
   string description of their favorite pet using pattern matching, e.g., "Alice Smith's
   favorite pet is a Golden Retriever dog":

   ```ocaml
   val describe_favorite_pet : person -> string
   ```

   To generate the string to return, you could use the string concatenation operator
   (`^`) that we've seen before. But there's a better way: the string PPX!

   OCaml has a powerful feature called *PPX*[^3], in
   which the computer writes some boilerplate code for you. There are specific points in
   the syntax where OCaml allows a *PPX extension*, using some telltale special characters
   like `@@` and `%`.

[^3]: PPX stands for "PreProcessor eXtension". OCaml programmers have written many useful
      PPX rewriters. Some ppxs use brackets like [% ... ] to stake out a region that the
      metaprogramming will interact with, which is how the string PPX works. The syntax is

      ```ocaml
      [%string "FORMAT_STRING"]
      ```

      where `"FORMAT_STRING"` uses `%{expression#Module}` to insert expressions into the
      resulting string:

      ```ocaml
      let string_ppx_example (i : int) (b : bool) (c : char) (s : string) =
        [%string
          "a ppx_string example with i + 1 = %{i + 1#Int}, b = %{b#Bool}, c = %{c#Char}, and s = %{s}"]
      ```

      Note that we don't have to include the module when the expression is already a
      string. When processed by the preprocessor, `string_ppx_example` would be rewritten
      as something like

      ```ocaml
      let string_ppx_example (i : int) (b : bool) (c : char) (s : string) =
        String.concat
          ~sep:""
          [ "a ppx_string example with i + 1 = "
          ; Int.to_string (i + 1)
          ; ", b = "
          ; Bool.to_string b
          ; ", c = "
          ; Char.to_string c
          ; ", and s = "
          ; s
          ]
      ;;
      ```

      The `String.concat` function takes a separator, and a list of strings to
      concatenate.

   <oxcaml data-oxcaml-run-trigger="manual">
   open Core

   (* Define [pet], the extended [person] record, and the updated [napoleon] and
      [janelle] instances here: *)


   (* Add your [describe_favorite_pet] definition here: *)


   (* Tests: *)
   let () = assert (String.equal (describe_favorite_pet napoleon) "Napoleon Bonaparte's favorite pet is a Newfoundland dog")
   let () = assert (String.equal (describe_favorite_pet janelle) "Janelle Monáe's favorite pet is a Siamese cat")
   </oxcaml>

Continue to the [next page](./tour-of-ocaml-08.md).
