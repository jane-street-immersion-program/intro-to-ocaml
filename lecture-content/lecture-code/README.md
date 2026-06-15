# JSIP intro-to-OCaml lecture skeleton

A minimal one-file project, built with the **external opam toolchain** (not the Jane Street
tools), for live-coding the lecture examples. Type everything --- types, functions, and the
`print_s`/`printf` calls --- into `main.ml` during the lecture.

## Commands

Run these from this directory.

- `dune build` --- compile.
- `dune exec ./main.exe` --- build and run `main.ml` (a top-level `let () = print_s ...`
  prints when you run it).
- `dune fmt` --- format the code (uses the `.ocamlformat` in this directory).

## Notes

- `[@@deriving ...]`, `[%sexp ...]`, and `print_s` come from `ppx_jane` + `core`, wired up
  in `dune`.
- A few warnings (unused vars/values, etc.) are relaxed in `dune` so partially-written code
  typed during the lecture still builds.
