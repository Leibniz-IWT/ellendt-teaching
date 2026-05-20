# Debugging Exercise — 2D Heat Conduction

## What the code does

`heat_conduction_FDM_buggy.m` simulates steady-state heat conduction in a
316L stainless steel plate (0.1 m × 0.1 m) with a uniform internal heat
source.  All four walls are held at fixed temperatures (Dirichlet boundary
conditions), each at a different value.  The temperature field T(x, y) is
found by solving the 2D Poisson equation using a finite difference stencil
on a uniform grid.  The iteration runs until the relative change between
successive sweeps falls below a tolerance.

The result is shown as a colour map of the temperature field.

## Your task

The code contains **four deliberate errors**.  Find and fix all of them.

Use any combination of:
- physical reasoning — does the result look right?
- careful reading of the code
- comparison against what you would expect from the problem setup
- asking an AI assistant to review specific parts of the code

## Hints  (read only what you need)

<details>
<summary>Hint</summary>

Run the code first and look at the numbers it prints and the colour map it
produces.  Before reading a single line of code, ask yourself: does this
result make physical sense for a water-cooled steel plate?

</details>

## Files

| File | Description |
|---|---|
| `heat_conduction_FDM_buggy.m` | The code to debug |
