% JSIP: Exchanges & the Matching Engine
% Aaron Bauer, 2026

# What is an exchange?

- Market _participants_ connect and send orders
- Operate during set hours (the "trading day")
- The exchange never takes a position itself --- it owns no shares and makes no
  bets. It only _matches_ other people's orders.
- It doesn't _set_ prices either. Prices are wherever a buyer and a seller agree;
  the exchange just enforces the _rules_ of who trades with whom, and in what order.

# Why have exchanges?

- Make it easy for buyers and sellers to find each other
- Public information about prices
- The exchange charges fees

# What is an order?

- In the morning lecture, we had side, price (limit), and size
- We'll also need _symbol_, since multiple things trade on an exchange
- The price is a **limit** --- the _worst_ price you're willing to accept:
  - a BUY at $150.00 means "pay $150.00 _or less_"
  - a SELL at $150.00 means "receive $150.00 _or more_"
  - That's why these are called **limit orders**. (Some real exchanges also offer
    _market orders_ --- "trade at any price" --- but our exchange is limit-only.)

# The order book

- The book is the central data structure. Two sides:
  - **Bids** (buyers), sorted high → low --- the most anyone will pay is on top
  - **Asks**/**offers** (sellers), sorted low → high --- the least anyone will take is on top
- The two sides that sit nearest each other are the **best bid** and **best ask**;
  together they're the **BBO** (best bid and offer). The gap between them is the
  **spread**; the average is the **mid**.
- A **price level** aggregates _all_ the size resting at one price.
- Draw the book as a price ladder (asks above, bids below):

```
         ASKS  (sellers)
    $150.20    150
    $150.10    100   <- best ask
   ----------------  spread = $0.20,  mid = $150.00
    $149.90    100   <- best bid
    $149.80    200
         BIDS  (buyers)
```

# What happens when an order is sent to the exchange?

- The **matching engine** takes the incoming order (the **aggressor**) and compares
  it to the resting orders on the _opposite_ side of the book.
- Orders **match**, or **cross**, when their prices overlap (a buy priced at or
  above the best ask, or a sell at or below the best bid). A cross **fills** the
  orders --- a trade happens.
- A fill always executes at the **resting** order's price, not the aggressor's
  (see the worked examples --- the aggressor often gets _price improvement_).
- Which resting order goes first? **Price-time priority**: best price first; among
  orders at the same price, earliest arrival first.
- Any unfilled size of a Day order becomes a **resting** order on the book.
- It could instead be an **Immediate or Cancel (IOC)** order, which never rests:
  fill what it can right now, cancel any remainder.
- There are other order types, some of which you'll implement.

# Worked examples

Walk through these on the board, updating the ladder after each. Participants:
Alice, Bob, Charlie.

## 1. An order with nothing to match → it rests

- Book is empty. **Alice: BUY 100 @ $149.90.**
- No asks to trade against → her order rests, becoming the best (only) bid.
  BBO is now `$149.90 / --`.
- Takeaway: an order that can't trade isn't rejected --- it _provides liquidity_
  and waits.

## 2. A simple cross

- Resting: **Bob SELL 100 @ $150.00.** Incoming: **Alice BUY 100 @ $150.00.**
- Prices meet exactly → trade **100 @ $150.00**. Both orders fully filled; book empty.

## 3. Price improvement (fill at the _resting_ price)

- Resting: **Bob SELL 100 @ $150.00.** Incoming: **Alice BUY 100 @ $151.00.**
- Alice was willing to pay up to $151.00, but the trade happens at Bob's
  **$150.00** --- she saves $1.00/share.
- The rule (aggressor trades at the resting price) is never worse for the
  aggressor. The reward for resting _first_ is that you set the price.

## 4. Partial fill

- Resting: **Bob SELL 60 @ $150.00.** Incoming: **Alice BUY 100 @ $150.00.**
- 60 shares trade @ $150.00. Alice still wants 40; no more asks → her remaining
  **40 rests as a bid @ $150.00.**
- One order can be filled in pieces, possibly over time and against many counterparties.

## 5. Sweeping multiple price levels

- Resting asks: **50 @ $150.00**, **50 @ $150.10**, **50 @ $150.20.**
- Incoming: **Alice BUY 200 @ $150.20.** Fills in price order:
  - 50 @ $150.00, then 50 @ $150.10, then 50 @ $150.20
- 150 shares filled at _progressively worse_ prices --- the deeper you sweep, the
  more you pay. (Her _average_ price is worse than the best ask she started with.)
- 50 shares still wanted: a **Day** order would rest @ $150.20; an **IOC** cancels
  the leftover 50 and never rests.

## 6. Price-time priority

- Resting asks:
  - **A: 100 @ $10.00** (arrived first)
  - **B: 50 @ $10.00** (arrived second)
  - **C: 200 @ $10.05**
- Incoming: **BUY 300 @ $10.05.** Fills **A → B → C**:
  - A first (best price _and_ earliest), then B (same price, later), then C (worse price)
- _Price_ beats time; among equal prices, _time_ (earliest) wins. This is why "when
  you got here" matters --- and a big reason exchanges and trading systems care so
  much about speed.
- (Aside: the starter engine gets this rule _wrong_ on purpose --- fixing it is one
  of your exercises.)

> **Think–pair–share.**
> Start from the ladder book at the top (bids `$149.90 x100`, `$149.80 x200`;
> asks `$150.10 x100`, `$150.20 x150`). An incoming **SELL 250 @ $149.80 (Day)**
> arrives.
> (a) What trades, and at what prices?
> (b) What's left on the book afterward?
>
> _Discuss:_ a sell at $149.80 crosses the bids (sell ≤ best bid). Price-time order
> fills the best bid first: **100 @ $149.90**, then **150 @ $149.80**. The seller is
> fully filled (100 + 150 = 250). The $149.80 level had 200, so **50 @ $149.80**
> remains as a bid; the asks are untouched. Note the first 100 filled at $149.90 ---
> _better_ than the seller's $149.80 limit. Price improvement again.

# What else might a participant send?

- Cancel (pull a resting order off the book)
- Modify
- Request for information (e.g. show me the book)

# What comes out of the exchange?

- **Private** messages, back to the participant who sent the order --- the lifecycle
  of _their_ order:
  - Accept, Reject, Fill, Cancel
  - Lifecycle: accepted → resting → (partially) filled → filled / cancelled
- **Public marketdata**, broadcast to everyone watching:
  - **Trade reports**: a trade happened (symbol, price, size)
  - **BBO updates**: the best bid/ask changed
- Marketdata is **anonymous** --- it tells you _what_ traded, never _who_. You see
  the market, not your competitors.

# Sequencing: one order at a time

- The engine processes orders **one at a time, in the order received.**
- That's what makes "time priority" well-defined --- and makes the whole system
  **deterministic**: the same orders in the same order always produce the same
  result. (Handy for fairness, and for testing by replay.)

# Tie it back to the system you'll build

Map each board-diagram component to what we just covered:

- **Matching engine** --- the book + the matching rules (today's focus).
- **Gateway** --- how participants connect, send orders, and get responses; it also
  _sequences_ the incoming order flow into the engine.
- **Marketdata dissemination** --- broadcasting the public trade-report and BBO stream.
- **Trading systems / bots** --- the participants (including market makers) that
  actually send the orders.
- Over the next four weeks you'll extend and improve every one of these.
