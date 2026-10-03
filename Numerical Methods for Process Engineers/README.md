# Numerical Methods for Process Engineers

Welcome to the course materials for **Numerical Methods for Process Engineers**. 

This folder contains interactive Python scripts and Jupyter Notebooks (`.ipynb`) that accompany the lectures. These notebooks are designed to bridge the gap between mathematical theory and practical implementation, allowing you to run, explore, and modify the numerical algorithms we discuss in class.

## 📂 Course Contents

The materials are organized chronologically by topic. Click on any folder to view the notebooks for that unit:

* **[01 - Introduction](./01-Introduction)**
  * `heron_method.ipynb`
    * Heron's (Babylonian) method for square roots — geometric interpretation, effect of the initial guess, connection to Newton's method and quadratic convergence
  * `ieee754_number_representation.ipynb`
    * How computers store numbers (IEEE 754) — representation error, absorption, summation order, gaps between floats (ULP), single vs. double precision, safe comparisons, Inf/NaN
* **[02 - Roots](./02-roots)**
  * `root_finding.ipynb`
    * Bisection, secant (regula falsi) and Newton's method — iteration tables, convergence orders, cases where Newton fails, and a robust hybrid strategy
* **[03 - Integration](./03-integration)**
  * `numerical_integration.ipynb`
    * Riemann sums, midpoint, trapezoidal and Simpson's rule — convergence study, accuracy vs. cost, and why Simpson's rule is special
  * `adaptive_trapezoidal.ipynb`
    * Adaptive trapezoidal rule — the number of segments is doubled until a prescribed relative tolerance is met
* **[04 - Interpolation and Regression](./04-Interpolation%20and%20Regression)**
  * `interpolation.ipynb`
    * Linear, polynomial (Vandermonde), Lagrange and cubic spline interpolation — the overshoot problem, the Runge function, and step-by-step spline construction
  * `regression.ipynb`
    * Least-squares regression — design matrix and normal equations, polynomial degree, other basis functions, geometric interpretation, and choosing the right number of parameters
* **[05 - Linear Equation Systems](./05-linear%20equation%20systems)**
  * `iterative_linear_solvers.ipynb`
    * Jacobi and Gauss–Seidel iteration — matrix splitting, the role of diagonal dominance, scaling to larger systems, and comparison with a direct solver
* **[06 - Ordinary Differential Equations](./06-ordinary%20differential%20equations)**
  * `what_is_an_ode.ipynb`
    * What an ODE looks like — vector fields, initial value problems, classification, equilibria and stability, and a gallery of examples to explore
  * `ode_solvers.ipynb`
    * Explicit Euler, implicit Euler, trapezoidal rule and classical RK4 — convergence study, stability of implicit methods, and a visualisation of the four RK4 slopes
* **[07 - Finite Difference Method](./07-finite%20difference%20method)**
  * `fdm_heat_conduction.ipynb`
    * 1D transient heat conduction — explicit vs. implicit schemes, stability (Fourier number), the tridiagonal matrix (TDMA), convective boundary conditions, and grid convergence
  * `pde_heat2d.ipynb`
    * 2D heat equation in a plate with an explicit scheme — the stability limit, what happens when it is violated, and grid refinement
  * `crank_nicolson.ipynb`
    * Crank–Nicolson method for reaction–diffusion equations — Fisher–KPP travelling waves, second-order accuracy in time, and Turing pattern formation in a two-variable system
* **[08 - Finite Element Method](./08-finite%20element%20method)**
  * `fem_complete.ipynb`
    * FEM step by step — linear and quadratic shape functions, assembly and solution for 1D heat conduction, extension to 2D on triangles and quads, mesh refinement and stiffness-matrix sparsity

---

## 🚀 How to Run the Notebooks

To interact with these files, you will need an environment capable of running Jupyter Notebooks (Python). 

**Option 1: Run Locally (Recommended)**
1. Clone or download this repository to your computer.
2. Ensure you have Python installed, along with `jupyter` and standard scientific libraries (like `numpy`, `scipy`, and `matplotlib`).
3. Open your terminal or command prompt, navigate to this folder, and type:
   ```bash
   jupyter notebook
   ```
