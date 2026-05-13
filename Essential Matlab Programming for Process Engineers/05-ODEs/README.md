# ODEs Applied: The Falling, Cooling Droplet

---

## Topic

This lecture series introduces ordinary differential equations (ODEs) through a single physical problem that is progressively made more realistic across five parts. A molten metal droplet falls through a gas and eventually solidifies. Starting from a single scalar ODE for velocity, the model is extended step by step — adding falling distance, temperature-dependent gas properties, a coupled heat equation, and finally solidification — until it captures the full physics of gas atomisation.

The direction field script stands at the beginning as a geometric introduction: before any numerical integration, students see what an ODE *looks like* in the phase plane.

Each part introduces exactly one new concept so that the added complexity is always motivated by a physical argument, not a mathematical one.

---

## Files

| File | Companion function | State vector | New concept |
|---|---|---|---|
| `directionalfield.m` | `droplet.m` | `u` | Direction field — geometric view of the ODE |
| `fallingdroplet1.m` | `droplet.m` | `u` | Single ODE, terminal velocity via `fzero` |
| `fallingdroplet2.m` | `droplet2.m` | `[u, x]` | System of ODEs, velocity and falling distance |
| `fallingdroplet3.m` | `droplet3.m` | `[u, x]` | Temperature-dependent gas properties, fixed droplet temperature |
| `fallingdroplet4.m` | `droplet4.m` | `[u, x, T]` | Coupled heat equation with temperature-dependent properties |
| `fallingdroplet5.m` | `droplet5.m` | `[u, x, T]` | Solidification |

---

## Physical Background

A sphere of diameter $d$ and density $\rho_T$ falls through a gas of density $\rho_G$ and viscosity $\eta_G$. Three forces act on it: gravity, buoyancy, and drag. At the same time, the hot droplet loses heat to the cooler gas by forced convection and eventually solidifies.

This scenario is the core of **gas atomisation**: liquid metal is disintegrated into droplets by a high-velocity gas jet, and the droplets cool and solidify during free fall. Understanding $u(t)$, $x(t)$, and $T(t)$ is directly relevant to predicting particle size, cooling rate, and microstructure.

---

## Equations

### 0 — Direction field (`directionalfield.m`)

Before solving the ODE numerically, the slope field visualises $du/dt$ at every point in the $(t, u)$ plane using `quiver`. Each arrow has a unit horizontal component and a vertical component equal to $du/dt$, so its slope matches the ODE right-hand side:

$$\text{arrow direction} \propto \left(1,\; \frac{du}{dt}\right)$$

This gives the geometric interpretation: the numerical solution produced by `ode45` is the unique curve that is everywhere tangent to the field and passes through the initial condition. Equilibria (terminal velocity) appear as horizontal arrows where $du/dt = 0$.

### 1 — Equation of motion (Part 1)

Newton's second law for a sphere in free fall, with drag:

$$\frac{du}{dt} = g - \frac{3}{4}\frac{\rho_G}{\rho_T}\frac{1}{d}\,u^2\,C_d(Re)$$

The drag coefficient $C_d$ uses the Schiller-Naumann correlation, valid for $Re < 1000$:

$$C_d = \frac{24}{Re}\left(1 + 0.15\,Re^{0.687}\right), \qquad Re = \frac{u\,d\,\rho_G}{\eta_G}$$

**Terminal velocity** is the steady state $du/dt = 0$. This is a root-finding problem solved with `fzero`. Gas properties are constant in this part.

### 2 — Velocity and falling distance (Part 2)

The state vector becomes $\mathbf{y} = [u,\, x]^\top$ with the second equation:

$$\frac{dx}{dt} = u$$

This extends a scalar ODE to a **system of ODEs** — the key step for understanding how `ode45` handles multi-variable problems. Outputs are $u(t)$, $x(t)$, and the phase portrait $u(x)$. Gas properties remain constant.

### 3 — Temperature-dependent gas properties, fixed droplet temperature (Part 3)

The gas properties $\rho_G$, $\eta_G$, $c_{p,G}$, and $\lambda_G$ are no longer constants but functions of temperature, passed as function handles in the parameter struct:

```matlab
p.rho_G    = @(T, P)  ...   % gas density           [kg/m^3]
p.eta_G    = @(T)     ...   % dynamic viscosity      [Pa*s]
p.cp_G     = @(T)     ...   % heat capacity          [J/(kg*K)]
p.lambda_G = @(T)     ...   % thermal conductivity   [W/(m*K)]
```

The droplet temperature is **fixed** at a prescribed value in this part — so the state vector is still $[u, x]^\top$ and the energy equation is not yet integrated. This isolates the effect of gas property variation on the drag and trajectory before the full coupling is introduced.

This part demonstrates **function handles as struct fields** — a clean pattern for passing property models into ODE right-hand-side functions without global variables.

### 4 — Coupled heat equation (Part 4)

The state vector becomes $\mathbf{y} = [u,\, x,\, T]^\top$. The energy balance for the droplet gives:

$$\frac{dT}{dt} = -\frac{6\,\alpha}{d\,\rho_T\,c_{p,T}}\,(T - T_\infty)$$

where $6/d$ is the surface-area-to-volume ratio for a sphere ($A/V = \pi d^2 / (\pi d^3/6) = 6/d$).

The heat transfer coefficient $\alpha$ comes from the **Ranz-Marshall correlation**:

$$Nu = \frac{\alpha\,d}{\lambda_G} = 2 + 0.6\,Re_\text{heat}^{1/2}\,Pr^{1/3}, \qquad Pr = \frac{c_{p,G}\,\eta_G}{\lambda_G}$$

Two distinct Reynolds numbers appear:

| Symbol | Temperature used | Purpose |
|---|---|---|
| $Re_\text{drag}$ | local droplet temperature $T$ | drag coefficient $C_d$ in momentum equation |
| $Re_\text{heat}$ | film temperature $T_\text{film} = (T + T_\infty)/2$ | Ranz-Marshall heat transfer correlation |

All gas properties are now temperature-dependent (from Part 3), so momentum and energy are **fully coupled**: the droplet temperature changes the gas properties, which changes both drag and heat transfer.

### 5 — Solidification (Part 5)

When the droplet temperature reaches the solidification temperature $T_s$, latent heat is released, modifying the energy equation. During solidification the temperature is held at $T_s$ while the solid fraction $f_s$ evolves:

$$\frac{df_s}{dt} = \frac{1}{L}\,\frac{6\,\alpha}{d\,\rho_T}\,(T_s - T_\infty)$$

where $L$ is the latent heat of solidification [J/kg]. Integration stops (or switches back to the cooling equation) once $f_s = 1$. The state vector gains a fourth component or solidification is handled as an event, depending on implementation.

---

## MATLAB Concepts Introduced

| Concept | Where introduced |
|---|---|
| `quiver` for direction fields | `directionalfield.m` |
| `ode45` with a scalar ODE | Part 1 |
| `fzero` for terminal velocity (root of $du/dt = 0$) | Part 1 |
| System of ODEs, state vector `y = [y1; y2; ...]` | Part 2 |
| Phase portrait `plot(y(:,2), y(:,1))` | Part 2 |
| Function handles as struct fields `p.f = @(T) ...` | Part 3 |
| Evaluating properties at film vs. free-stream temperature | Part 4 |
| Two Reynolds numbers in the same RHS function | Part 4 |
| ODE event detection or conditional switching for phase change | Part 5 |

---

## Learning Goals

After completing this lecture series, students should be able to:

1. **Read a direction field** and identify equilibria, stability, and the geometric meaning of the ODE solution as a curve tangent to the field.
2. **Formulate an equation of motion** as a first-order ODE and identify the terminal velocity as a root of the right-hand side, solved with `fzero`.
3. **Call `ode45`** correctly: understand the function signature `f(t, y)`, the role of the time span, and how to extract individual state variables from the solution matrix.
4. **Extend a scalar ODE to a system** by augmenting the state vector, and explain why `dx/dt = u` is an ODE even though it contains no new physics.
5. **Use function handles as struct fields** to pass temperature-dependent property models cleanly into an ODE right-hand-side function, and explain why this is preferable to hardcoded constants.
6. **Add a coupled energy equation** to a mechanical ODE system, explain why the $6/d$ factor appears in the cooling rate, and apply the Ranz-Marshall correlation with the correct film temperature.
7. **Extend the model to include solidification** and describe how latent heat modifies the energy equation at the phase transition.

---

## Further Reading

- Incropera, F.P.; DeWitt, D.P.: *Fundamentals of Heat and Mass Transfer*, Chapter 7 (External Flow, sphere correlations)
- Ranz, W.E.; Marshall, W.R.: *Chem. Eng. Prog.* 48 (1952) 141–146 (original Ranz-Marshall correlation)
- Schiller, L.; Naumann, A.: *Z. Ver. Dtsch. Ing.* 77 (1933) 318–320 (drag correlation)
