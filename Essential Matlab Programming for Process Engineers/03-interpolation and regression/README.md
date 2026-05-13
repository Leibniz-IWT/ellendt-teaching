# Interpolation & Regression

---

## Topic

This lecture uses real thermophysical property data for nitrogen gas from the NIST WebBook to introduce two fundamentally different ways of constructing a continuous function from a discrete set of measurements: **interpolation** and **regression**. The key distinction — interpolation passes through every data point, regression does not — is demonstrated visually and quantified through the coefficient of determination R².

---

## Files

| File | Description |
|---|---|
| `nitrogen-1bar.txt` | Tab-separated NIST data: $T$, $c_p$, $\mu$, $\rho$ for N₂ at 1 bar, 200–2000 K, 19 points, 12 reference header lines |
| `interpolation_regression.m` | Main script (Sections 1–7) |
| `R2.m` | Helper function: coefficient of determination |

---

## Physical Background

The data covers nitrogen gas from 200 K to 2000 K at 1 bar — a range relevant to combustion, heat exchangers, and gas atomisation processes. Three properties are examined:

- **Specific heat capacity** $c_p(T)$ [J g⁻¹ K⁻¹] — weak, non-monotonic variation with temperature
- **Dynamic viscosity** $\mu(T)$ [Pa·s] — smooth increase following power-law behaviour
- **Density** $\rho(T)$ [kg m⁻³] — closely follows the ideal gas law $\rho \propto 1/T$

These three properties have very different shapes and therefore respond differently to polynomial fits of the same order — which is exactly what Section 7 exploits.

---

## Equations

### 1 — Linear interpolation

Between two known points $(T_i,\, y_i)$ and $(T_{i+1},\, y_{i+1})$, the interpolated value at $T$ is:

$$y(T) = y_i + \frac{y_{i+1} - y_i}{T_{i+1} - T_i}\,(T - T_i), \qquad T_i \leq T \leq T_{i+1}$$

The result is a piecewise linear function that is continuous but has kinks (discontinuous first derivative) at every data point.

### 2 — Cubic spline interpolation

A cubic spline fits a separate cubic polynomial $S_i(T) = a_i + b_i T + c_i T^2 + d_i T^3$ in each interval $[T_i, T_{i+1}]$. The four coefficients per interval are determined by requiring:

- $S_i(T_i) = y_i$ and $S_i(T_{i+1}) = y_{i+1}$ — passes through data points
- $S_i'(T_{i+1}) = S_{i+1}'(T_{i+1})$ — continuous first derivative
- $S_i''(T_{i+1}) = S_{i+1}''(T_{i+1})$ — continuous second derivative (smooth curvature)

With $n$ data points and $n-1$ intervals there are $4(n-1)$ unknowns. The four conditions per interior knot, plus two end conditions (natural spline: $S''=0$ at both ends), give exactly $4(n-1)$ equations.

The result is a $C^2$-continuous curve — smooth in both slope and curvature everywhere.

### 3 — PCHIP (Piecewise Cubic Hermite Interpolating Polynomial)

PCHIP also uses a cubic polynomial per interval, but instead of global $C^2$ continuity it enforces **local monotonicity**: if the data is monotone in an interval, the fit is monotone there too, and if the data has a local extremum, so does the fit.

This makes PCHIP more conservative than splines in regions with steep gradients, avoiding oscillations at the cost of reduced smoothness ($C^1$ only, not $C^2$).

### 4 — Polynomial regression (least squares)

Regression seeks the polynomial of degree $p$

$$\hat{y}(T) = a_0 + a_1 T + a_2 T^2 + \cdots + a_p T^p$$

that minimises the **sum of squared residuals**:

$$\text{SSres} = \sum_{i=1}^{n} \bigl(y_i - \hat{y}(T_i)\bigr)^2$$

Minimising SSres with respect to the coefficients $a_0, \ldots, a_p$ leads to the **normal equations**:

$$\mathbf{A}^\top \mathbf{A}\, \mathbf{a} = \mathbf{A}^\top \mathbf{y}$$

where $\mathbf{A}$ is the Vandermonde matrix ($A_{ij} = T_i^{j-1}$). MATLAB's `polyfit` solves this system. The fitted polynomial generally does **not** pass through the data points.

### 5 — Coefficient of determination R²

R² measures the fraction of the total variance in $y$ that is explained by the fit:

$$R^2 = 1 - \frac{\text{SSres}}{\text{SStot}}, \qquad \text{SStot} = \sum_{i=1}^{n}(y_i - \bar{y})^2$$

$R^2 = 1$ is a perfect fit; $R^2 = 0$ means the model explains no more variance than the mean alone. For interpolation $R^2 \equiv 1$ by construction (SSres = 0), so R² is only meaningful for regression.

---

## Interpolation vs. Regression — the key distinction

| Property | Interpolation | Regression |
|---|---|---|
| Passes through data points? | **Always** (by construction) | Generally not |
| Number of parameters | $n$ (one per data point) | $p+1 \ll n$ |
| Useful when… | Data is accurate (e.g. NIST reference tables) | Data contains noise, or a compact formula is needed |
| Risk | Oscillation between points (especially high-degree polynomials) | Underfitting if $p$ is too low |
| Extrapolation | Very unreliable | Unreliable, but a polynomial formula can be evaluated anywhere |

---

## MATLAB Concepts Introduced

| Concept | Where used |
|---|---|
| `readtable` with tab delimiter and header line skip | Section 1 |
| `interp1` with `'linear'`, `'spline'`, `'pchip'` flags | Sections 3–4 |
| `polyfit` / `polyval` for polynomial regression | Sections 5–7 |
| R² as a goodness-of-fit metric | Sections 5, 7 and `R2.m` |
| `subplot` and `sgtitle` for multi-panel figures | Throughout |
| Drawing residual lines to visualise fit error | Section 6 |

---

## Learning Goals

After completing this lecture, students should be able to:

1. **Explain the difference** between interpolation and regression and identify which is appropriate for a given dataset and purpose.
2. **Apply `interp1`** with at least three different method flags and explain qualitatively why they behave differently on sparse data.
3. **Recognise spline oscillation** as a risk when data is sparse or the underlying function changes curvature sharply.
4. **Apply `polyfit` and `polyval`** to fit polynomials of varying degree and evaluate them on a fine grid.
5. **Compute and interpret R²**: explain what it measures, why it always equals 1 for interpolation, and when a high R² does *not* mean the fit is good (overfitting).
6. **Choose a fit degree** by balancing R² against physical plausibility and extrapolation behaviour — illustrated here by the contrast between $c_p$, $\mu$, and $\rho$.

---

## Further Reading

- NIST WebBook: https://webbook.nist.gov/chemistry/fluid/
