<script src="https://julesjacobs.com/misc/oxcaml/playground/oxcaml-embed.js"></script>

## Solutions to the [Previous Exercises](./tour-of-ocaml-10.md#exercises)

1.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   type person =
     { first_name : string
     ; last_name : string
     ; age : int ref
     ; email : string option
     }

   let birthday person = person.age := !(person.age) + 1
   </oxcaml>

2.
   <oxcaml data-oxcaml-run-trigger="manual-after-initial">
   open Core

   let map_ref r ~f = ref (f !r)
   </oxcaml>

## End of the Tour

You've reached the end of the OCaml tour. Now would be a great time to review
any lingering questions you have about what you've seen so far.
