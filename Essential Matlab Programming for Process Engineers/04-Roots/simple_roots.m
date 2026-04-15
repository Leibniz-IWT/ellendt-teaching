%% ========================================================================
%  ROOT FINDING
%  Simple examples using fzero
%  ========================================================================
%
%  This script demonstrates root finding in MATLAB using the built-in
%  fzero function, which combines bisection, secant, and inverse
%  quadratic interpolation (Brent's method).
%
%  Topics covered:
%    1. Plotting a function to locate roots visually
%    2. Finding roots with fzero (single starting point)
%    3. Finding roots with fzero (bracketed interval)
%    4. Problematic cases: tangent roots, non-smooth functions
%
%  Author: Dr. Nils Ellendt
% =========================================================================

clear all; close all; clc;

%% --- Global figure settings ---
set(0, 'DefaultAxesFontSize', 13);
set(0, 'DefaultAxesFontName', 'Times New Roman');
set(0, 'DefaultLineLineWidth', 1.5);
set(0, 'DefaultAxesBox', 'on');
set(0, 'DefaultFigureColor', 'w');

%% ========================================================================
%  1 — Define and plot the function
% =========================================================================
%  f(x) = sqrt(x) - 0.1*x - 1
%
%  This function has TWO roots: one near x ≈ 1 and one near x ≈ 100.
%  Plotting first is essential to understand where the roots are.

f = @(x) sqrt(x) - 0.1*x - 1;

x = linspace(0, 120, 500);

figure('Units', 'centimeters', 'Position', [2 8 20 12]);
plot(x, f(x), 'b-', 'LineWidth', 2); hold on;
yline(0, 'k--', 'LineWidth', 1);
xlabel('x');
ylabel('f(x)');
title('f(x) = \surdx - 0.1x - 1', 'FontWeight', 'bold');
grid on;

%% ========================================================================
%  2 — Find roots with fzero
% =========================================================================
%  fzero needs a starting guess OR a bracket [a, b] where f changes sign.
%  Different starting points find different roots.

%  Root near x = 0
x_r1 = fzero(f, 0);
fprintf('  Root 1 (start near 0):   x = %.6f,  f(x) = %.2e\n', ...
    x_r1, f(x_r1));

%  Root near x = 100
x_r2 = fzero(f, 100);
fprintf('  Root 2 (start near 100): x = %.6f,  f(x) = %.2e\n', ...
    x_r2, f(x_r2));

%  Mark the roots on the plot
plot(x_r1, 0, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
plot(x_r2, 0, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
text(x_r1 + 2, 0.15, sprintf('x_1 = %.2f', x_r1), ...
    'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');
text(x_r2 + 2, 0.15, sprintf('x_2 = %.2f', x_r2), ...
    'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');
legend('f(x)', 'y = 0', 'Roots', 'Location', 'southwest');

%% ========================================================================
%  3 — Using a bracket [a, b] instead of a single guess
% =========================================================================
%  A bracket guarantees convergence (if f(a)*f(b) < 0).

x_r1_bracket = fzero(f, [0, 10]);
x_r2_bracket = fzero(f, [50, 120]);

fprintf('\n  Bracketed root 1: [0, 10]    → x = %.6f\n', x_r1_bracket);
fprintf('  Bracketed root 2: [50, 120]  → x = %.6f\n', x_r2_bracket);

%% ========================================================================
%  4 — Problematic cases
% =========================================================================
%  Not every function is easy for fzero. Here are two classic pitfalls.

figure('Units', 'centimeters', 'Position', [2 8 30 12]);

%  Case A: sin(x) + 1 — touches zero but does not cross
%  fzero may find it, but the result is fragile.
subplot(1,2,1);
x_plot = linspace(-5, 10, 500);
plot(x_plot, sin(x_plot) + 1, 'b-', 'LineWidth', 2); hold on;
yline(0, 'k--', 'LineWidth', 1);
try
    x0_sin = fzero(@(x) sin(x) + 1, 0);
    plot(x0_sin, 0, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    title_str = sprintf('sin(x)+1:  root at x = %.4f', x0_sin);
catch ME
    title_str = 'sin(x)+1:  fzero failed!';
end
xlabel('x'); ylabel('f(x)');
title({title_str; '(tangent root — no sign change)'}, ...
    'FontWeight', 'bold');
grid on;

%  Case B: |x| — not differentiable at the root
%  fzero struggles because there is no sign change.
subplot(1,2,2);
plot(x_plot, abs(x_plot), 'b-', 'LineWidth', 2); hold on;
yline(0, 'k--', 'LineWidth', 1);
try
    x0_abs = fzero(@(x) abs(x), 1);
    plot(x0_abs, 0, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    title_str = sprintf('|x|:  "root" at x = %.4f', x0_abs);
catch ME
    title_str = '|x|:  fzero failed!';
end
xlabel('x'); ylabel('f(x)');
title({title_str; '(no sign change — |x| \geq 0 everywhere)'}, ...
    'FontWeight', 'bold');
grid on;

sgtitle('Problematic Cases for Root Finding', 'FontWeight', 'bold');

fprintf('\n  ⚠  sin(x)+1 has a tangent root (touches zero, no crossing)\n');
fprintf('  ⚠  |x| has no sign change — fzero may return unexpected results\n');
