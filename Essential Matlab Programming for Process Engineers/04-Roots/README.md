# Root Finding with `fzero` — Applied to Terminal Velocity

---

## Topic

This lecture introduces numerical root finding with MATLAB's `fzero` function. The concept is first demonstrated on a simple mathematical function with two known roots, including cases where `fzero` is unreliable. It is then applied to a physically meaningful problem: finding the terminal velocity of a falling sphere. Because terminal velocity is the steady state of the equation of motion ($du/dt = 0$), it is the root of a nonlinear algebraic equation — root finding in disguise.

The lecture closes by sweeping over four decades of sphere diameter using `logspace` to produce a terminal velocity map, connecting root finding, drag physics, and log-log visualisation in a single script.

---

## Files

| File | Description |
|---|---|
| `simple_roots.m` | Abstract introduction to `fzero`: single guess, brackets, problematic cases |
| `terminal.m` | Right-hand side function $du/dt$; root is the terminal velocity |
| `falling_sphere.m` | Sweeps sphere diameter from 1 µm to 1 mm; plots $u_\text{term}(d)$ and $u_\text{term}(Re)$ |

---

## Physical Background

A sphere of diameter $d$ and density $\rho_s$ falls through a fluid of density $\rho_g$ and kinematic viscosity $\nu$. Gravity accelerates the sphere; drag decelerates it. The sphere reaches **terminal velocity** $u_\infty$ when these forces exactly balance and acceleration vanishes.

The drag force depends on the Reynolds number, which in turn depends on velocity — making the force balance a nonlinear algebraic equation that must be solved numerically.

---

## Equations

### 1 — Equation of motion

Newton's second law for a sphere falling through a fluid:

$$\frac{du}{dt} = g - \frac{3}{4}\frac{\rho_g}{\rho_s}\frac{1}{d}\,u^2\,C_d(Re)$$

The drag coefficient uses the **Schiller-Naumann** correlation (valid for $Re < 1000$):

$$C_d = \frac{24}{Re}\left(1 + 0.15\,Re^{0.687}\right), \qquad Re = \frac{u\,d}{\nu}$$

### 2 — Terminal velocity as a root-finding problem

Terminal velocity is the velocity at which $du/dt = 0$:

$$g - \frac{3}{4}\frac{\rho_g}{\rho_s}\frac{1}{d}\,u_\infty^2\,C_d(Re_\infty) = 0$$

Because $C_d$ itself depends on $u_\infty$ through $Re$, this cannot be solved analytically. It is a nonlinear equation $f(u) = 0$, solved numerically with `fzero`.

### 3 — Brent's method (what `fzero` does internally)

`fzero` combines three methods adaptively:

| Method | Convergence | Requirement |
|---|---|---|
| Bisection | Linear — slow but guaranteed | Sign change in bracket $[a, b]$ |
| Secant | Superlinear | Two recent iterates |
| Inverse quadratic interpolation | Cubic | Three recent iterates |

At each step it picks the method that is both safe (stays inside the bracket) and fastest. A bracket $[a, b]$ with $f(a) \cdot f(b) < 0$ guarantees convergence; a single starting point does not.

### 4 — Problematic cases

`fzero` requires a sign change to bracket the root. Two cases where it fails or returns unreliable results:

- **Tangent root** — $f(x) = \sin(x) + 1$ touches zero at $x = -\pi/2$ but does not cross. No sign change exists, so no bracket can be formed.
- **Non-negative function** — $f(x) = |x|$ is everywhere $\geq 0$. The "root" at $x = 0$ has no sign change; `fzero` may return a near-zero value but the result is not guaranteed.

### 5 — Parameter sweep with `logspace`

The terminal velocity is computed for sphere diameters spanning four decades:

$$d \in [10^{-6},\, 10^{-3}] \text{ m} \quad (1\,\mu\text{m} \text{ to } 1\,\text{mm})$$

`logspace(-6, -3, 100)` generates 100 points equally spaced on a logarithmic scale — appropriate here because the physics is scale-invariant (the result plotted on log-log axes collapses onto a power-law curve at low and high Re).

The Reynolds number at terminal velocity:

$$Re_\infty = \frac{u_\infty\,d}{\nu}$$

is plotted on the second axis to show where the Schiller-Naumann correlation is valid ($Re < 1000$) and where it breaks down.

---

## MATLAB Concepts Introduced

| Concept | Where used |
|---|---|
| Anonymous functions `f = @(x) ...` | `simple_roots.m` |
| `fzero` with single starting point | `simple_roots.m`, `falling_sphere.m` |
| `fzero` with bracket `[a, b]` | `simple_roots.m`, `falling_sphere.m` |
| `try` / `catch` for handling solver failures gracefully | `simple_roots.m` |
| Parameter struct passed into a function | `terminal.m`, `falling_sphere.m` |
| `logspace` for logarithmically spaced vectors | `falling_sphere.m` |
| `loglog` for log-log plots | `falling_sphere.m` |
| Pre-allocating output arrays with `zeros` | `falling_sphere.m` |
| `for` loop over a parameter range | `falling_sphere.m` |

---

## Learning Goals

After completing this lecture, students should be able to:

1. **Explain what a root is** and why many engineering problems (equilibria, force balances, intersection of curves) reduce to $f(x) = 0$.
2. **Always plot first** — identify the number and approximate location of roots visually before calling `fzero`.
3. **Call `fzero`** with a single starting point and with a bracket, and explain when a bracket is necessary for guaranteed convergence.
4. **Recognise when `fzero` will fail**: tangent roots and non-negative functions have no sign change, so no bracket exists.
5. **Use `try`/`catch`** to handle solver failures gracefully so that a script continues even when one case fails.
6. **Connect root finding to a physical problem**: formulate the terminal velocity condition as $f(u) = 0$ and solve it with `fzero`.
7. **Use `logspace`** to sweep a parameter over decades and `loglog` to visualise power-law relationships.

---

## Further Reading

- Press, W.H. et al.: *Numerical Recipes*, Chapter 9 (Root Finding and Nonlinear Sets of Equations)
- Brent, R.P.: *Algorithms for Minimization without Derivatives*, Chapter 4 (1973) — original description of Brent's method used inside `fzero`
- Schiller, L.; Naumann, A.: *Z. Ver. Dtsch. Ing.* 77 (1933) 318–320 (drag correlation)
