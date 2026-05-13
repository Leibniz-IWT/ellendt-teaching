# 1D Unsteady Heat Conduction in a Sphere

---

## Topic

This lecture solves the transient heat equation in spherical coordinates using MATLAB's built-in PDE solver `pdepe`. A solid sphere at elevated temperature is cooled by convection at its surface. The solution field $T(r,t)$ is visualised as a surface plot, as temperature profiles at fixed radii, and as radial profiles at fixed times. A cross-sectional 2D slice is reconstructed by rotating the 1D solution around the axis.

The central learning objective is understanding how to cast a real PDE problem into the canonical form required by `pdepe`, and how to interpret the solution through the dimensionless **Biot** and **Fourier** numbers.

---

## Files

| File | Description |
|---|---|
| `heat_pde_sphere.m` | Complete script including all local functions |

---

## Physical Background

The problem models a sphere (radius $R = 5$ mm, steel-like properties) initially at $T_0 = 800$ K, cooled by a convective flow at $T_\infty = 293$ K. Because the geometry is spherically symmetric, the 3D problem reduces to a 1D problem in the radial coordinate $r$.

Two dimensionless numbers characterise the problem completely:

**Biot number** — ratio of internal conduction resistance to external convection resistance:

$$\text{Bi} = \frac{h R}{k}$$

For $\text{Bi} \ll 1$, temperature gradients inside the sphere are negligible and the much simpler **lumped capacitance model** (Section below) is valid. For larger Bi, a full distributed solution is needed. With the parameters in this script, $\text{Bi} \approx 0.125$ — borderline, which makes this a useful test case.

**Fourier number** — dimensionless time, measuring how far diffusion has penetrated relative to the sphere radius:

$$\text{Fo} = \frac{\alpha\, t}{R^2}, \qquad \alpha = \frac{k}{\rho c_p}$$

At $\text{Fo} \gtrsim 0.2$ the temperature field at the centre has begun to respond to the surface cooling. At $t_\text{end}$ this script reaches $\text{Fo} \approx 1.1$, so the full transient response is captured.

---

## Equations

### 1 — The PDE: heat equation in spherical coordinates

In spherical symmetry (no $\theta$, $\phi$ dependence), the energy balance for a solid gives:

$$\rho c_p \frac{\partial T}{\partial t} = \frac{1}{r^2} \frac{\partial}{\partial r}\!\left( r^2\, k\, \frac{\partial T}{\partial r} \right)$$

### 2 — pdepe canonical form

`pdepe` solves equations of the form:

$$c(x,t,u,u_x)\,\frac{\partial u}{\partial t} = x^{-m}\,\frac{\partial}{\partial x}\!\left(x^m\, f(x,t,u,u_x)\right) + s(x,t,u,u_x)$$

Matching the heat equation term by term:

| pdepe symbol | Physical meaning | Value here |
|---|---|---|
| $m$ | geometry flag (0 = slab, 1 = cylinder, 2 = sphere) | $2$ |
| $c$ | capacity coefficient | $\rho c_p$ |
| $f$ | flux term | $k\,\partial T/\partial r$ |
| $s$ | source term | $0$ |

### 3 — Initial condition

$$T(r,\, 0) = T_0 = 800 \text{ K} \quad \text{(uniform)}$$

### 4 — Boundary conditions

`pdepe` expects boundary conditions in the form $p + q \cdot f = 0$ on each side.

**Left boundary ($r = 0$) — symmetry:**  
For $m = 2$, `pdepe` enforces symmetry automatically; $p_l$ and $q_l$ are ignored.

**Right boundary ($r = R$) — convective (Robin) condition:**  
The physical condition is that the conductive flux at the surface equals the convective flux to the ambient:

$$-k\,\frac{\partial T}{\partial r}\bigg|_{r=R} = h\,(T_R - T_\infty)$$

Rewritten in pdepe form with $f = k\,\partial T/\partial r$:

$$\underbrace{h\,(T_R - T_\infty)}_{p_r} + \underbrace{1}_{q_r} \cdot f = 0$$

### 5 — Lumped capacitance model (reference / comparison)

When $\text{Bi} \ll 1$, the temperature is approximately uniform inside the sphere and the analytical solution is:

$$\frac{T(t) - T_\infty}{T_0 - T_\infty} = \exp\!\left(-\frac{h\, A}{\rho c_p V}\, t\right) = \exp\!\left(-\frac{3h}{\rho c_p R}\, t\right)$$

where $A/V = 3/R$ for a sphere. Comparing this exponential decay with the distributed `pdepe` solution shows when the lumped approximation breaks down (centre lags behind the surface for larger Bi).

### 6 — Cross-section reconstruction via polar coordinates

The 1D radial solution $T(r, t^*)$ is rotated through $\phi \in [0, 2\pi]$ to produce a 2D cross-sectional image. Cartesian coordinates are obtained from:

$$x = r \cos\phi, \qquad y = r \sin\phi$$

In MATLAB: `[Xc, Yc] = pol2cart(PHI, RR)` with `T_slice = repmat(T_mid, N_phi, 1)'` tiling the 1D profile along the azimuthal direction.

---

## MATLAB Concepts Introduced

| Concept | Where used |
|---|---|
| `pdepe` — canonical form, `m` flag, function signatures | Section 3 |
| **Local functions** inside a script file | `HeatPDE`, `HeatPDE_IC`, `HeatPDE_BC`, `local_get_props`, `local_get_bc` |
| Parameter passing via dedicated getter functions | `local_get_props`, `local_get_bc` |
| `surf` with `shading interp` and `view(0,90)` for 2D colour maps | Section 5 |
| Selecting rows/columns of a solution matrix for slice plots | Sections 6–7 |
| `repmat` and `pol2cart` for 2D visualisation from a 1D result | Section 8 |
| `fprintf` for a structured diagnostic summary | Section 4 |

---

## Learning Goals

After completing this lecture, students should be able to:

1. **Identify the pdepe canonical form** and extract $c$, $f$, $s$ from a given PDE by coefficient comparison.
2. **Choose the geometry flag** $m \in \{0, 1, 2\}$ for Cartesian slab, cylindrical, or spherical problems.
3. **Formulate Robin boundary conditions** in the $p + q \cdot f = 0$ form required by `pdepe`.
4. **Interpret Biot and Fourier numbers** physically and decide whether a lumped capacitance approximation is justified.
5. **Navigate the solution matrix** `SOL(it, ix)` to extract time slices and radial profiles for plotting.
6. **Reconstruct a 2D cross-section** from a 1D rotationally symmetric solution using `repmat` and `pol2cart`.
7. **Organise parameters** in dedicated getter functions so that material properties and boundary values are defined in exactly one place.

---

## Further Reading

- Incropera, F.P.; DeWitt, D.P.: *Fundamentals of Heat and Mass Transfer*, Chapter 5 (Transient Conduction)
- MathWorks Documentation: `pdepe` — [https://de.mathworks.com/help/matlab/ref/pdepe.html](https://de.mathworks.com/help/matlab/ref/pdepe.html)
