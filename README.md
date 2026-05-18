<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

# OCaml as a Calculator

Follow along with these steps in `utop` (open a terminal and run `utop`).
The `#` at the start of a line is indicating the `utop` prompt;
copy the rest of the line and hit `:kbd: Enter` to run it.
Lines following a prompt are showing the expected `utop` output.
Our first step is to open `Core`:

```ocaml
# open Core;;
```

Throughout Jane Street, we use the `Core` library everywhere, a more full-featured and
capable replacement for OCaml's standard library. By opening `Core`, we make the
definitions it contains available without having to reference `Core` explicitly. This is
required for many of the examples in the tour and in the remainder of the bootcamp, as
well as ~all of the code written at Jane Street.

Now let's try a few simple numerical calculations:

```ocaml
# 3 + 4;;
- : int = 7
# 8 / 3;;
- : int = 2
# 3.5 +. 6.;;
- : float = 9.5
# 30_000_000 / 300_000;;
- : int = 100
# 3 * 5 > 14;;
- : bool = true
```

By and large, this is pretty similar to what you'd find in any programming
language, but a few things jump right out at you:

- We needed to type `;;` in order to tell the toplevel that it should
  evaluate an expression. This is a peculiarity of the toplevel that is not
  required in standalone programs.

- After evaluating an expression, the toplevel first prints the type of the
  result, and then prints the result itself.

- OCaml allows you to place underscores in the middle of numeric literals to
  improve readability.

- OCaml carefully distinguishes between `float`, the type for floating-point
  numbers, and `int`, the type for integers. The types have different
  literals (`6.` instead of `6`) and different infix operators (`+.` instead
  of `+`), and OCaml doesn't automatically cast between these types. This can
  be a bit of a nuisance, but it has its benefits, since it prevents some
  kinds of bugs that arise in other languages due to unexpected differences
  between the behavior of `int` and `float`. For example, in many languages,
  `1 / 3` is zero, but `1.0 /. 3.0` is a third. OCaml requires you to be
  explicit about which operation you're using.

We can also create a variable to name the value of a given expression, using the `let`
keyword. This is known as a _let binding_:

```ocaml
# let x = 3 + 4;;
val x : int = 7
# let y = x + x;;
val y : int = 14
```

After a new variable is created, the toplevel tells us the name of the
variable (`x` or `y`), in addition to its type (`int`) and value (`7` or
`14`).

Note that there are some constraints on what identifiers can be used for
variable names. Punctuation is excluded, except for `_` and `'`, and
variables must start with a lowercase letter or an underscore. Thus, these
are legal:

```ocaml
# let x7 = 3 + 4;;
val x7 : int = 7
# let x_plus_y = x + y;;
val x_plus_y : int = 21
# let x' = x + 1;;
val x' : int = 8
```

The following examples, however, are not legal:

```ocaml
# let Seven = 3 + 4;;
Line 1, characters 5-10:
Error: Unbound constructor Seven
# let 7x = 7;;
Line 1, characters 5-7:
Error: Unknown modifier x for literal 7x
# let x-plus-y = x + y;;
Line 1, characters 7-11:
Error: Syntax error
```

This highlights that variables can't be capitalized, can't begin with
numbers, and can't contain dashes.

From here, it's up to you whether you want to follow along in `utop`.
If you're curious about how something works,
trying out variations in `utop` is a great way to test a hypothesis.
But it can also get cumbersome to enter long expressions at the prompt.

# Functions

The `let` syntax can also be used to define a function:

<oxcaml utop>
let square x = x * x
square 2
square (square 2)
</oxcaml>

Functions in OCaml are values like any other, which is why we use the
`let` keyword to bind a function to a variable name, just as we use `let` to
bind a simple value like an integer to a variable name. When using `let` to
define a function, the first identifier after the `let` is the function name,
and each subsequent identifier is a different argument to the function. Thus,
`square` is a function with a single argument.

Now that we're creating more interesting values like functions, the types have gotten more
interesting too. `int -> int` is a function type, in this case indicating a function that
takes an `int` and returns an `int`. We can also write functions that take multiple
arguments.

<oxcaml utop>
let ratio x y = Float.of_int x /. Float.of_int y
ratio 4 7
</oxcaml>

Note that in OCaml, function arguments are separated by spaces instead
of by parentheses and commas, which is more like the UNIX shell than
it is like traditional programming languages such as Python or Java.

The preceding example also happens to be our first use of
modules. Here, `Float.of_int` refers to the `of_int` function
contained in the `Float` module. This is different from what you might
expect from an object-oriented language, where dot-notation is
typically used for accessing a method of an object. Note that module
names always start with a capital letter.

Modules can also be opened to make their contents available without
explicitly qualifying by the module name. We did that once already, when we
opened `Core` earlier. We can use that to make this code a little easier to
read, both avoiding the repetition of `Float` above, and avoiding use of the
slightly awkward `/.` operator. In the following example, we open the
`Float.O` module, which has a bunch of useful operators and functions that
are designed to be used in this kind of context. Note that this causes the
standard int-only arithmetic operators to be shadowed locally.

<oxcaml utop>
let ratio x y =
  let open Float.O in
  of_int x / of_int y
;;
</oxcaml>

We used a slightly different syntax for opening the module, since we
were only opening it in the local scope inside the definition of
`ratio`. There's also a more concise syntax for local opens, as you
can see here.

<oxcaml utop>
let ratio x y = Float.O.(of_int x / of_int y)
</oxcaml>

The notation for the type-signature of a multiargument function may be a little surprising
at first. For the moment, think of the arrows as separating different arguments of the
function, with the type after the final arrow being the return value. Thus, `int -> int ->
float` describes a function that takes two `int` arguments and returns a `float`.

We can also write functions that take other functions as arguments. Here's an
example of a function that takes three arguments: a test function and two
integer arguments. The function returns the sum of the integers that pass the
test:

<oxcaml utop>
let sum_if_true test first second =
  (if test first then first else 0)
  + (if test second then second else 0)
</oxcaml>

If we look at the inferred type signature in detail, we see that the first
argument is a function that takes an integer and returns a boolean, and that
the remaining two arguments are integers. Here's an example of this function
in action:

<oxcaml utop>
let even x = x % 2 = 0
sum_if_true even 3 4
sum_if_true even 2 4
</oxcaml>

Note that in the definition of `even`, we used `=` in two different ways:
once as part of the `let` binding that separates the thing being defined from
its definition; and once as an equality test, when comparing `x % 2` to
`0`. These are very different operations despite the fact that they share
some syntax.

# Exercises

Practice the syntax for defining functions, conditionals, and working with floats, by
implementing the following two functions in the editor below.
This OCaml playground editor works a lot like `utop`, except that state is not preserved;
each time you hit **_Run_**, the code is re-evaluated from scratch.

1. A function `min3 : int -> int -> int -> int` that returns the smallest of the three
   `int` input arguments.
2. A function `min3_float : float -> float -> float -> float` that returns the smallest of
   the three `float` input arguments.

The editor below is pre-populated with `assert`-based test cases. Add your function
definitions above the tests and hit **_Run_**; if a test fails, you'll see an
`Assert_failure` message pointing at the failing line.

<oxcaml data-oxcaml-run-trigger="manual">
open Core

(* Add your solutions here: *)


(* Tests: *)
let () = assert (min3 5 9 3 = 3)
let () = assert (min3 (-3) 7 (-3) = (-3))
let () = assert (min3 0 0 1 = 0)

let () = assert Float.O.(min3_float 4.0 7.0 1.0 = 1.0)
let () = assert Float.O.(min3_float 0.5  (-0.5) 1.5 = (-0.5))
let () = assert Float.O.(min3_float 2.0 2.0 3.0 = 2.0)
</oxcaml>
