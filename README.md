# VerifyThis2023
Solutions of team The Sparkans for VerifyThis 2023 competition

For SPARK, we are using the current development version.

For Why3, we are using the published version 1.6.0.

## Challenge 1

To prove the solution in SPARK, go to subdirectory `challenge1/spark` and run

```
gnatprove -P lists.gpr
```

On an 8 cores Linux laptop, it terminates in less that 2 minutes, and proves
that the SPARK implementation is free of run-time errors, terminates and
satisfies its functional specification.

To see the solution in Why3, go to subdirectory `challenge1/why3`. It contains
a likely separation logic description of the input (covering lasso case as
well), starting setting up a memory model, but nothing is proven yet.

## Challenge 2

To see the solution in SPARK, go to subdirectory `challenge2/spark`. The lemmas
for correctly instantiating a formal unbounded hash set were proved on the
redefined equality. The only procedure that requires termination proof is
`Mk_Not`, for which the structural subprogram variant is justified on the two
recursive calls, as they are made on copied of the fields `Left` and
`Right`. It is assumed that there is enough memory to always allocate more
nodes.

We hit an internal error when instantiating the container with `Node_Acc`. The
workaround was to use a wrapper record `Node_Wrap` as element of the hashed
set.

To see the solution in Why3, go to subdirectory `challenge2/why3`. The main
solution in in the `challenge2.mlw` with hash-consing primitive partially
proved. The code was modified to use ID instead of addresses, and shortcutting
the hash to constant time. The `oldversion.mlw` contains an early attempt to
model physical equality in Why3.
