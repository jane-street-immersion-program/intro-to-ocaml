open! Core

(* varient type *)
type side =
  | Buy (* Buy is a variant constructor or tag, must be capitalized *)
  | Sell
[@@deriving sexp]

(* record type *)
type order =
  { side : side (* field_name : field_type *)
  ; price : float
  ; size : int
  }
[@@deriving sexp]

(* notional value is price times size *)
(* defining a function with let FUNCTION_NAME ARG1 ARG2 ... = FUNCTION_BODY *)
let notional order = order.price *. Float.of_int order.size
let list_of_ints = [ 1; 2; 3 ]

let book =
  [ { side = Buy; price = 100.5; size = 10 }
  ; { side = Sell; price = 101.5; size = 5 }
  ; { side = Buy; price = 100.; size = 7 }
  ]
;;

let bigger_book = { side = Sell; price = 101.5; size = 3 } :: book

(* List.map : 'a list -> ~f:('a -> 'b) -> 'b list 'a (tick-a or alpha) is a
   type variable. It can be any type, but all 'a in a signature must be the
   same ~f is labeled parameter *)
let book_notionals = List.map ~f:notional bigger_book

(* [%message] is a pre-processor extension (PPX) *)

let float_not_equal (x : float) (y : float) : bool = not (Float.equal x y)
let price = 100.5
let describe price = print_endline [%string "order at %{price#Float}"]

(* module Float_option = struct type t = | Some of float | None end *)

module Last_trade = struct
  type t =
    { last_trade_price : float
    ; last_trade_time : Time_ns.t
    }
end

(* module Last_trade_option = struct type t = | Some of Last_trade.t | None
   end *)

(* module Option = struct type 'a t = | Some of 'a | None end *)

(* placing an order to buy = making a bid places an order to sell = making an
   ask or offer best bid and offer (BBO) *)
module Market = struct
  type t =
    { best_bid : float option
    ; best_ask : float option
    ; last_trade : Last_trade.t option
    }
end

let mid_price (market : Market.t) : float option =
  match market.best_bid with
  | None -> None
  | Some best_bid ->
    (match market.best_ask with
     | None -> None
     | Some best_ask -> Some ((best_bid +. best_ask) /. 2.))
;;

let mid_price' (market : Market.t) : float option =
  match market.best_bid, market.best_ask with
  | None, _ | _, None -> None
  | Some best_bid, Some best_ask -> Some ((best_bid +. best_ask) /. 2.)
;;

module Result = struct
  type ('ok, 'error) t =
    | Ok of 'ok
    | Error of 'error
end

let mid_price_if_else (market : Market.t) =
  if Option.is_some market.best_bid && Option.is_some market.best_ask
  then
    Some
      ((Option.value_exn market.best_bid +. Option.value_exn market.best_ask)
       /. 2.)
  else None
;;

let mid_price2 (market : Market.t) : (float, string) Result.t =
  match market.best_bid, market.best_ask with
  | None, None -> Error "no bid or ask"
  | None, _ -> Error "no bid"
  | _, None -> Error "no ask"
  | Some best_bid, Some best_ask -> Ok ((best_bid +. best_ask) /. 2.)
;;

let%expect_test "demo" =
  print_s [%message (book : order list)];
  describe 123.4;
  [%expect
    {|
    (book
     (((side Buy) (price 100.5) (size 10)) ((side Sell) (price 101.5) (size 5))
      ((side Buy) (price 100) (size 7))))
    order at 123.4
    |}]
;;
