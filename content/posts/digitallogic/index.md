+++
title = "Boolean logic"
date = "2026-01-06"

[taxonomies]
tags=["example"]

[extra]
comment = true
+++

Note: This requires the `mathjax` and `mathjax_dollar_inline_enable` option set to `true` in `[extra]` section.

<!-- # Inline Math -->
<!---->
<!-- - $(a+b)^2$ = $a^2 + 2ab + b^2$ -->
<!-- - A polynomial P of degree d over $\mathbb{F}_p$ is an expression of the form -->
<!--   $P(s) = a_0 + a_1 . s + a_2 . s^2 + ... + a_d . s^d$ for some -->
<!--   $a_0,..,a_d \in \mathbb{F}_p$ -->
<!---->
<!-- # Displayed Math -->
<!---->
<!-- $$ -->
<!-- p := (\sum_{k∈I}{c_k.v_k} + \delta_v.t(x))·(\sum_{k∈I}{c_k.w_k} + \delta_w.t(x)) − (\sum_{k∈I}{c_k.y_k} + \delta_y.t(x)) -->
<!-- $$ -->

<!-- # Factoring Radical Expressions -->
<!-- <p align="center"> We are trying to simplify this as much as possible</p> -->
<!-- $$ -->
<!-- \frac{2x^2-8}{x^2-4x+4} -->
<!-- $$ -->
<!---->
<!-- <p align="center">The top expression simplifies to 2 monomials</p> -->
<!-- $$ -->
<!-- \frac{2(x+2)(x-2)}{x^2-4x+4} -->
<!-- $$ -->
<!---->
<!---->
<!---->
<!-- <p align="center">factor out the bottom equation</p> -->
<!-- $$ -->
<!-- \frac{2(x+2)\cancel{(x-2)}}{\cancel{(x-2)}(x-2)} -->
<!-- $$ -->
<!---->
<!-- # The Final Solution -->
<!-- $$ -->
<!--     \frac{2(x+2)}{x-2} -->
<!-- $$ -->

| Input 1 | Input 2 | Output |
|--------|--------|------|
| 0 | 0 | 0 |
| 1 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 1 | 0 |


   There is only one row that we should put our attention on
   which is the second row

   This comes out to a simple boolean expression

$$
   A \land \lnot B
$$

Currently we're solving a circuit that has one input and one output.







{{ img(src="circuit1.png", alt="Paging diagram", width=200) }}

The solution is that you pipe both of the inputs through an and gate. so A and not B through an AND gate




## XOR GATE

this one is gonna be a little more complex just because it involves more boolean logic

| Input 1 | Input 2 | Output |
|--------|--------|------|
| 0 | 0 | 0 |
| 1 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 1 | 0 |


If you we take all the rows that have an output of 1 which are the most relevant ones.

We have 1-0-1 and  0-1-1


so then the logic expression that corresponds to the circuit would be as follows

$$
    (A \land \lnot B) \lor (\lnot A \land B)
$$

then we just need to translate that to a circuit

