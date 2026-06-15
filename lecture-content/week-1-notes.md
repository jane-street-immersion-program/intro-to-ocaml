% JSIP: Intro to OCaml
% Aaron Bauer, 2026

# Why OCaml, and what is a type?

- Long ago, programs dealt with data only as raw 1s and 0s. A **type** = a description of
  what a piece of data _is_ and what you can _do_ with it.
- OCaml is **compiled**; the compile step includes **typechecking**, which catches misuse
  _before the program runs_ --- whole categories of bugs become impossible. This is the payoff
  for dealing with the strictness of the compiler.
- Two themes to repeat all week --- they're _why_ our code looks the way it does:
  - **Immutable by default.** Don't modify a value, build a new one. Easier to reason about.
  - **Make illegal states unrepresentable.** Design types so nonsensical values can't be
    constructed; the compiler then enforces our rules for free. _Most of today is this idea._
- **`Core`** = Jane Street's replacement for the standard library; ~everything starts with
  `open Core`.

  ```ocaml
  open Core
  ```

# 1. Modeling a single order

- Goal: represent an **order** --- someone wants to buy or sell some size at some price.
- Which **side**? Exactly two cases --- a job for a **variant** (an "or" type):

  ```ocaml
  type side =
    | Buy
    | Sell
  ```

  - `Buy` / `Sell` are the _constructors_ (tags). The compiler knows nothing else is
    possible.
  - An example of "illegal states unrepresentable": can't build a `side` that's neither
    (contrast with representing the side as a string).

- An order groups several _named_ values --- a **record**:

  ```ocaml
  type order =
    { side : side
    ; price : float
    ; size : int
    }
  ```

  - `type` keyword; names before the colons are **fields**. Note `price : float` vs
    `size : int` --- distinct types, which bites in a second.

- Construct one and `let`-bind it:

  ```ocaml
  let my_order = { side = Buy; price = 100.5; size = 10 }
  ```

  - `let <name> = <expr>` is a **let binding**. Functions are values too, so `let` defines
    them as well.

- First **function** --- `notional` = price × size. Type the naive version first and let it
  fail:

  ```ocaml
  let notional order = order.price * order.size
  ```

  - Doesn't compile! `int` and `float` are strictly separate: different operators
    (`+ - * /` vs `+. -. *. /.`), no silent coercion. `price` is a `float`, `*` is _integer_
    multiplication:

    ```
    Error: This expression has type float but an expression was expected of type int
    ```

  - Fix with `*.` and `Float.of_int`:

    ```ocaml
    let notional order = order.price *. Float.of_int order.size
    ```

  - Name after `let` = function name; args separated by spaces (not commas/parens).
  - Field access via dot: `order.price`.
  - Type is `order -> float`; read the arrow as "produces." A multi-arg type like
    `int -> int -> float` = two args, last type is the result.
  - The strict split is annoying but heads off real bugs (in many languages `1 / 3` is `0`).

## Many orders: lists

- One order isn't much use --- an exchange tracks a whole **book**. A **list** holds any
  number of values, all the _same_ type:

  ```ocaml
  let book =
    [ { side = Buy; price = 100.5; size = 10 }
    ; { side = Sell; price = 101.0; size = 5 }
    ; { side = Buy; price = 100.0; size = 7 }
    ]
  ```

  - Type is `order list`; can't mix types in a list.

- To see what's in the book we'll want to print it. `Core` values print as
  **s-expressions** ("sexps"), and we get a sexp for our _own_ types by deriving one ---
  tack a `[@@deriving sexp]` clause onto the type definitions we have so far:

  ```ocaml
  type side =
    | Buy
    | Sell
  [@@deriving sexp]

  type order =
    { side : side
    ; price : float
    ; size : int
    }
  [@@deriving sexp]
  ```

  - This generates `sexp_of_side` and `sexp_of_order` (and the reverse parsers) for free, so
    we can print the whole book:

    ```ocaml
    print_s [%sexp (book : order list)]
    ```

  - `[%sexp (book : order list)]` turns `book` into a sexp using those generated functions,
    and `print_s` prints it. It's idiomatic to put a deriving clause on essentially every
    type --- we lean on the generated `sexp` constantly, especially once we start writing
    expect tests.

- Lists are **immutable**. "Add" with `::` ("cons", prepends one element) → a _new_ list;
  the original is untouched:

  ```ocaml
  let bigger_book = { side = Sell; price = 101.5; size = 3 } :: book
  ```

- `Core`'s **`List`** module is full of list functions; `List.map` transforms every element
  into a new list:

  ```ocaml
  let notionals = List.map book ~f:notional
  ```

  - `~f` is a _labeled argument_ --- we'll come back to it in §4.

- Say we want just the buy orders. `List.filter` keeps the elements for which `~f` returns
  `true`, so we need to compare each order's side to `Buy` --- i.e. an equality function for
  `side`. Instead of hand-writing one, we _extend_ the deriving clause with `equal` (and
  `compare`, which we'll want for sorting the book by price):

  ```ocaml
  type side =
    | Buy
    | Sell
  [@@deriving sexp, compare, equal]
  ```

  - Now we also have `equal_side` and `compare_side`, so filtering the book is a one-liner:

    ```ocaml
    let is_buy order = equal_side order.side Buy
    let buys = List.filter book ~f:is_buy
    ```

> **Think–pair–share #1.**
> For each expression: does it type-check, and if so what's its type?
>
> 1. `{ side = Sell; price = 99.0; size = 1 }`
> 2. `[ my_order; my_order ]`
> 3. `[ Buy; my_order ]`
> 4. `100.5 :: book`
>
> _Discuss:_ (1) `order`; (2) `order list`; (3) rejected --- list elements must share a type,
> and `Buy : side` is not an `order`; (4) rejected --- `book : order list`, so `::` wants an
> `order` on its left, not a `float`. Draw out: lists are homogeneous, and `::` has type
> `'a -> 'a list -> 'a list`.

## Reading compiler errors

- The compiler will reject your programs constantly at first; reading its errors is one of
  the most useful skills this week.
- Already saw the `int`/`float` mismatch. Two more you'll hit:
- **Application binds tighter than you think** → "too many arguments."

  ```ocaml
  let not_equal x y = not Float.equal x y
  ```

  ```
  Error: The function not has type bool -> bool
         It is applied to too many arguments
    This extra argument is not expected.
  ```

  - Greedy application: OCaml reads `((not Float.equal) x) y`, not "negate
    `Float.equal x y`." Fix with parens:

    ```ocaml
    let not_equal x y = not (Float.equal x y)
    ```

## Shadowing

- Re-bind a name in scope → it **shadows** the outer binding within that scope; a parameter
  `price` shadows an outer `price`:

  ```ocaml
  let price = 100.5
  let describe price = Printf.sprintf "order at %f" price  (* the parameter, not outer [price] *)
  ```

- Normal and idiomatic in OCaml.
- Gotcha: rename the param but leave the body saying `price` → it silently grabs the _outer_
  binding. Unused param → compiler warning; an `_`-prefix silences it.
- Discussion question: after renaming the param to `p`, which `price` does the body use, and
  what does the compiler now say about `p`?

# 2. A market where data might be missing

- A market for one symbol: best bid, best ask, last trade.

  ```ocaml
  type t =
    { best_bid : float
    ; best_ask : float
    ; last_trade_price : float
    ; last_trade_time : Time_ns.t
    }
  ```

- Are any of these _guaranteed_ to exist? (No best bid before any buy orders arrive; no last
  trade at the open.) So we need to represent "this value might not be here."
- In many languages you'd reach for a sentinel --- `null`, or in JavaScript `undefined`. The
  trouble: it's _invisible in the type_. A value claims to be a number but might secretly be
  absent, and nothing forces you to check; arithmetic on it just yields `NaN` (or a crash)
  far from the real mistake.
- So, with the tools we have, how would _we_ represent "a `float` that might be missing"? A
  variant with a "present" case and an "absent" case:

  ```ocaml
  module Float_option = struct
    type t = Some of float | None
  end
  ```

  - `module Name = struct ... end` just groups definitions (and keeps these `Some`/`None`
    from colliding with the next ones); full treatment in §5.
  - Jane Street style is for modules to define a single type called `t`

- We'd need the same shape for the timestamp:

  ```ocaml
  module Time_option = struct
    type t = Some of Time_ns.t | None
  end
  ```

- The _only_ difference between these is the type inside `Some`. Generalize with a **type
  variable**:

  ```ocaml
  module Option = struct
    type 'a t =
      | Some of 'a
      | None
  end
  ```

  - `'a` ("tick-a") is a placeholder for "any type," filled in per use: `float Option.t`,
    `Time_ns.t Option.t`. Writing one generic type instead of a dozen copies is **parametric
    polymorphism** (also `'a list`, which we've already seen).

- This is exactly OCaml's built-in **`option`** --- `Some price` / `None`, written
  `float option`. The compiler won't let you use it as a plain `float` until you've handled
  `None`. There's no hidden `null`: absence is _explicit in the type_.
- Rewrite the market with options:

  ```ocaml
  type t =
    { best_bid : float option
    ; best_ask : float option
    ; last_trade_price : float option
    ; last_trade_time : Time_ns.t option   (* [Time_ns.t] is Core's timestamp type *)
    }
  ```

- To build a market we'd write a constructor. Since every field is optional, this is a
  natural place for OCaml's **optional arguments** --- a labeled argument marked with `?` that
  the caller may omit:

  ```ocaml
  let create ?best_bid ?best_ask ?last_trade_price ?last_trade_time () =
    { best_bid; best_ask; last_trade_price; last_trade_time }
  ;;
  ```

  - An optional argument like `?best_bid` shows up inside the function as a `float option`
    --- exactly our field type --- so when the caller omits it the field is simply `None`
    (field punning ties the two together).
  - `create ~best_bid:100.5 ()` makes a market with only a bid; every other field defaults
    to `None`.
  - The trailing `()` is the standard trick: an optional argument can't be a function's last
    parameter (OCaml wouldn't know when you've stopped supplying them), so a final `unit`
    marks the end.
  - You'll also see optional arguments _with a default value_, e.g. an order constructor
    `let create_order ?(size = 1) ~side ~price () = ...` where an omitted `size` becomes `1`
    --- there the parameter is an ordinary `int`, not an option. Neither flavor is in the
    tour, but the starter code uses both.

- To _use_ an option, handle both cases with **`match`**:

  ```ocaml
  let bid_or_zero t =
    match t.best_bid with
    | None -> 0.
    | Some bid -> bid
  ;;
  ```

  - Each `|` is one case; the compiler checks exhaustiveness (drop the `None` case → it
    warns).
  - `bid_or_zero` is just to show syntax --- substituting a fake `0.` price is the very bug
    options exist to prevent.

> **Think–pair–share #2.**
> Suppose the market also gives us the total size at the best bid --- also absent
> when there's no bid.
> (a) How would you change the type to accommodate this?
> (b) What are the different states it could represent? Are all of them valid?

# 3. From "missing" to "what went wrong": designing error handling

We want to compute the **mid price** --- the average of the bid and ask. But either one might
be missing, so the result might not exist either.

- A first version returns a `float option`, using `match` to handle the missing cases:

  ```ocaml
  let mid (t : t) : float option =
    match t.best_bid with
    | None -> None
    | Some bid ->
      (match t.best_ask with
       | None -> None
       | Some ask -> Some ((bid +. ask) /. 2.))
  ;;
  ```

  - Every branch must produce the same type (`float option`), so the missing cases return
    `None` and the success case wraps its answer in `Some`.

- Matching one option inside another is clunky. We can match on **both at once** by building
  a tuple `t.best_bid, t.best_ask` and matching its shape:

  ```ocaml
  let mid' t =
    match t.best_bid, t.best_ask with
    | None, _ | _, None -> None
    | Some bid, Some ask -> Some ((bid +. ask) /. 2.)
  ;;
  ```

  - `None, _` uses the **wildcard** `_` to mean "anything," and the two failing patterns
    share one result via an _or-pattern_ (`|`). Read it as: "if either side is missing,
    `None`; otherwise average them."

## "It's missing" often isn't a good enough answer

`None` tells a caller the mid couldn't be computed, but not _why_. In some cases "why"
matters. Let's make the result carry an explanation.

- We could return a value that is _either_ a success _or_ an error message. That pattern is
  so common it has a name, **`Result`**, and it's just a variant with two type variables ---
  generic over both the success type (`'ok`) and the error type (`'error`):

  ```ocaml
  module Result = struct
    type ('ok, 'error) t =
      | Ok of 'ok
      | Error of 'error
  end
  ```

  - This `Result.t` is built into `Core`; we're just showing what's under the hood.

  ```ocaml
  let mid2 t =
    match t.best_bid, t.best_ask with
    | None, None -> Error "no bid or ask"
    | None, _ -> Error "no bid"
    | _, None -> Error "no ask"
    | Some bid, Some ask -> Ok ((bid +. ask) /. 2.)
  ;;
  ```

- Strings are friendly for humans but a poor format for _other code_ to act on (you can't
  reliably pattern-match on a string). So when the set of failures is known, model them as a
  variant too:

  ```ocaml
  module Mid_error = struct
    type t =
      | No_bid_or_ask
      | No_bid
      | No_ask
  end

  let mid3 t : (float, Mid_error.t) Result.t =
    match t.best_bid, t.best_ask with
    | None, None -> Error No_bid_or_ask
    | None, _ -> Error No_bid
    | _, None -> Error No_ask
    | Some bid, Some ask -> Ok ((bid +. ask) /. 2.)
  ;;
  ```

  - A caller can now `match` on the error and react differently to each case --- and the
    compiler makes sure they handle all of them.
  - (Aside: the `Error` _constructor_ of `Result` and the `Error` _module_ in `Core` are
    different things that share a name. If the compiler can't tell which variant you mean, a
    type annotation like the `: (float, Mid_error.t) Result.t` above disambiguates.)

- Carrying an error message around is _so_ common that `Core` provides **`Or_error.t`**, a
  specialization of `Result` whose error type is always `Error.t` (a lazy, structured error
  message):

  ```ocaml
  module Or_error = struct
    type 'ok t = ('ok, Error.t) Result.t
  end

  let mid4 (t : t) =
    match t.best_bid, t.best_ask with
    | None, None -> Or_error.error_string "no bid or ask"
    | None, _ -> Or_error.error_string "no bid"
    | _, None -> Or_error.error_string "no ask"
    | Some bid, Some ask -> Ok ((bid +. ask) /. 2.)
  ;;
  ```

  - `Or_error.t` is what you'll see most often in real code, so it's the one to remember.

> **Think–pair–share #3.**
> Write `print_mid : t -> unit` that calls `mid4` and prints the mid price when it succeeds,
> or `ERROR: ` followed by the error message when it fails.
>
> _Discuss:_ match on the `Or_error.t` that `mid4` returns:
>
> ```ocaml
> let print_mid t =
>   match mid4 t with
>   | Ok mid -> printf "%f\n" mid
>   | Error error -> print_endline ("ERROR: " ^ Error.to_string_hum error)
> ;;
> ```
>
> Draw out: a `_ Or_error.t` value forces the caller to handle both outcomes, and
> `Error.to_string_hum` turns the structured error back into a readable string.

# 4. First-class functions: removing duplication

Look back at `mid4`. Suppose we also want the **bid-ask spread** (ask minus bid). It needs
_exactly the same_ missing-data handling:

```ocaml
let bid_ask_spread (t : t) =
  match t.best_bid, t.best_ask with
  | None, None -> Or_error.error_string "no bid or ask"
  | None, _ -> Or_error.error_string "no bid"
  | _, None -> Or_error.error_string "no ask"
  | Some bid, Some ask -> Ok (ask -. bid)
;;
```

The only line that differs from `mid4` is the last one. Copy-pasting all that error handling
is a smell. In OCaml, **functions are values**, so we can factor out the shared part by
passing in the differing part _as a function argument_:

```ocaml
let of_bid_and_ask t ~f =
  match t.best_bid, t.best_ask with
  | None, None -> Or_error.error_string "no bid or ask"
  | None, _ -> Or_error.error_string "no bid"
  | _, None -> Or_error.error_string "no ask"
  | Some bid, Some ask -> Ok (f ~bid ~ask)
;;
```

- A function that takes another function as an argument is a **higher-order function**, and
  the function we pass is being used as a **first-class** value. This is everyday OCaml.
- `~f` is a **labeled argument**: at the call site we pass it by name (`~f:...`) rather than
  by position. Labels aren't only cosmetic --- here they're a _correctness_ tool. Look at the
  success branch, `Ok (f ~bid ~ask)`. If `f` instead took two plain, unlabeled `float`s,
  nothing would stop the spread function from computing `bid -. ask` when it meant
  `ask -. bid` --- the types line up, so the compiler stays silent while the sign comes out
  backwards. Because `~bid` and `~ask` are _labeled_, the function receiving them refers to
  each by name, so a swap is simply impossible. (Labels also let you pass arguments in any
  order.) `Core` functions use labels heavily for exactly these reasons --- e.g.
  `List.map list ~f:...`.

Now `mid` and the spread are one line each, sharing all the error logic. The differing piece
is an **anonymous function**, written with `fun`:

```ocaml
let mid5 t = of_bid_and_ask t ~f:(fun ~bid ~ask -> (bid +. ask) /. 2.)
let bid_ask_spread2 t = of_bid_and_ask t ~f:(fun ~bid ~ask -> ask -. bid)
let bid_ask_pair t = of_bid_and_ask t ~f:(fun ~bid ~ask -> bid, ask)
```

- An anonymous function is just a function with no name, handy when it's small and used
  once.
- `bid_ask_pair` returns a **tuple** `bid, ask` --- a fixed-size group of values (its type is
  `(float * float) Or_error.t`; the `*` here means "pair," nothing to do with
  multiplication).

> **Think–pair–share #4.**
> Using `of_bid_and_ask`, write `weighted_mid t` returning `0.6·bid + 0.4·ask` when both
> prices exist. How many lines of missing-data handling do you have to write?
>
> _Discuss:_ `let weighted_mid t = of_bid_and_ask t ~f:(fun ~bid ~ask -> (0.6 *. bid) +. (0.4 *. ask))`
> --- zero. `of_bid_and_ask` already owns every missing-data case. Reinforce: once the shared
> shape is a higher-order function, each new operation is a one-liner.

# 5. Packaging it up: modules and interfaces

We've been writing `module Result = struct ... end` inline. In a real project, **each `.ml`
file is itself a module**, and that's how the codebase you'll work in is organized.

- Instead of one giant file, we'd put our market type and its functions in `market.ml`.
  Throughout the rest of the code, we'd then refer to them as `Market.t`, `Market.mid`,
  `Market.bid_ask_spread`, and so on. (Module names are always capitalized; that's why
  `Float.of_int` and `List.map` look the way they do --- they're values living inside the
  `Float` and `List` modules.)
- Inside a module, the primary type is conventionally named **`t`**. So orders live in
  `order.ml` as `Order.t`, markets in `market.ml` as `Market.t`.

- A `.ml` file can have a companion **`.mli` file: its interface (or signature).** The
  `.mli` lists exactly what the module exposes to the outside world --- which types and which
  functions --- and hides everything else. Here are the interfaces for our two modules.
  `order.mli` is plain data, so we leave the record fields visible and `notional` lives here,
  alongside the type it operates on:

  ```ocaml
    open! Core

  type t =
    | Buy
    | Sell
  [@@deriving sexp, compare, equal]
  ```

  ```ocaml
  open! Core

  type t =
    { side : Side.t
    ; price : float
    ; size : int
    }
  [@@deriving sexp, compare, equal]

  val notional : t -> float
  ```

  `market.mli`, by contrast, keeps `type t` _abstract_ --- no definition, so the fields stay
  hidden:

  ```ocaml
  open! Core

  (** A market for a single symbol. Build one with [create]. *)
  type t

  val create
    :  ?best_bid:float
    -> ?best_ask:float
    -> ?last_trade_price:float
    -> ?last_trade_time:Time_ns.t
    -> unit
    -> t

  val mid : t -> float Or_error.t
  val bid_ask_spread : t -> float Or_error.t
  ```

  - Code outside `Market` can hold a `Market.t` and call these functions, but it _cannot_
    see or fiddle with the record fields directly --- a powerful version of "make illegal
    states unrepresentable": you control exactly how markets are built and used. (`Order.t`,
    being plain data, exposes its fields; the contrast is deliberate.)
  - A `val` line states a name and its type but no implementation. The interface is a
    contract; the `.ml` file must satisfy it.

- This is exactly how you'll navigate the exchange codebase: when you want to know what a
  module does, **read its `.mli` first.** It's the table of contents.
