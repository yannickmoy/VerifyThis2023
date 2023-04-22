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
