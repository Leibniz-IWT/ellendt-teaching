%% ========================================================================
%  INTERPOLATION & REGRESSION
%  Nitrogen Gas Properties from the NIST Database
%  ========================================================================
%
%  This script demonstrates interpolation and polynomial regression
%  using real thermophysical data for nitrogen gas at 1 bar.
%
%  Data source: NIST Chemistry WebBook
%               https://webbook.nist.gov/chemistry/fluid/
%
%  Topics covered:
%    1. Loading & plotting NIST data
%    2. Interpolation:  linear, spline, pchip
%    3. Sparse data:    5-point subset comparison
%    4. Regression:     polynomial fits (2nd–5th order), R²
%    5. Interpolation vs. Regression comparison
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
%  1 — Load NIST data
% =========================================================================
%  The file 'nitrogen-1bar.txt' is a tab-separated export from the NIST
%  WebBook with 12 header lines (references), then column names.

data = readtable('nitrogen-1bar.txt', ...
    'Delimiter',         '\t', ...
    'HeaderLines',       12, ...
    'ReadVariableNames', true);

T   = data.Temperature_K_;
cp  = data.Cp_J_g_K_;
mu  = data.Viscosity_Pa_s_;
rho = data.Density_kg_m3_;

fprintf('Loaded %d data points from %.0f K to %.0f K\n', ...
    length(T), T(1), T(end));

%% ========================================================================
%  2 — Overview: Thermophysical properties
% =========================================================================

figure('Units', 'centimeters', 'Position', [2 8 36 10]);

subplot(1,3,1);
plot(T, cp, 'ko-', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
xlabel('Temperature [K]');
ylabel('c_p [J g^{-1} K^{-1}]');
title('Specific Heat', 'FontWeight', 'bold');
axis([200 2000 1.0 1.3]);

subplot(1,3,2);
plot(T, mu, 'ko-', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
xlabel('Temperature [K]');
ylabel('\mu [Pa \cdot s]');
title('Dynamic Viscosity', 'FontWeight', 'bold');

subplot(1,3,3);
plot(T, rho, 'ko-', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
xlabel('Temperature [K]');
ylabel('\rho [kg m^{-3}]');
title('Density', 'FontWeight', 'bold');
axis([200 2000 0 2]);

sgtitle('Nitrogen at 1 bar — NIST Data', 'FontWeight', 'bold');

%% ========================================================================
%  3 — Interpolation methods (full dataset)
% =========================================================================
%  Fine grid for evaluation
Ti = linspace(T(1), T(end), 1000)';

%  Three interpolation methods
cp_linear = interp1(T, cp, Ti, 'linear');
cp_spline = interp1(T, cp, Ti, 'spline');
cp_pchip  = interp1(T, cp, Ti, 'pchip');

figure('Units', 'centimeters', 'Position', [2 8 36 10]);

subplot(1,3,1);
plot(T, cp, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k'); hold on;
plot(Ti, cp_linear, 'r-', 'LineWidth', 2);
xlabel('Temperature [K]');
ylabel('c_p [J g^{-1} K^{-1}]');
title('Linear', 'FontWeight', 'bold');
legend('NIST data', 'Linear', 'Location', 'southeast');

subplot(1,3,2);
plot(T, cp, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k'); hold on;
plot(Ti, cp_spline, 'b-', 'LineWidth', 2);
xlabel('Temperature [K]');
ylabel('c_p [J g^{-1} K^{-1}]');
title('Cubic Spline', 'FontWeight', 'bold');
legend('NIST data', 'Spline', 'Location', 'southeast');

subplot(1,3,3);
plot(T, cp, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k'); hold on;
plot(Ti, cp_pchip, 'Color', [0 0.6 0.3], 'LineWidth', 2);
xlabel('Temperature [K]');
ylabel('c_p [J g^{-1} K^{-1}]');
title('PCHIP', 'FontWeight', 'bold');
legend('NIST data', 'PCHIP', 'Location', 'southeast');

sgtitle('Interpolation of c_p(T) — full dataset (19 points)', ...
    'FontWeight', 'bold');

%% ========================================================================
%  4 — Sparse data: only 5 points
% =========================================================================
%  Reduce to 5 evenly spaced points — this is where methods diverge.

T5  = linspace(T(1), T(end), 5)';
cp5 = interp1(T, cp, T5, 'pchip');

%  Interpolate from the 5-point subset
cp5_linear = interp1(T5, cp5, Ti, 'linear');
cp5_spline = interp1(T5, cp5, Ti, 'spline');
cp5_pchip  = interp1(T5, cp5, Ti, 'pchip');

figure('Units', 'centimeters', 'Position', [2 8 20 12]);
plot(T, cp, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k'); hold on;
plot(T5, cp5, 'kv', 'MarkerSize', 10, 'LineWidth', 2);
plot(Ti, cp5_linear, 'k-',  'LineWidth', 1.5);
plot(Ti, cp5_spline, 'r-',  'LineWidth', 2);
plot(Ti, cp5_pchip,  'b-',  'LineWidth', 2);
xlabel('Temperature [K]');
ylabel('c_p [J g^{-1} K^{-1}]');
title('Interpolation from only 5 data points', 'FontWeight', 'bold');
legend('Original (19 pts)', '5-point subset', ...
       'Linear', 'Spline', 'PCHIP', 'Location', 'southeast');

%% ========================================================================
%  5 — Polynomial regression
% =========================================================================
%  Unlike interpolation, regression does NOT pass through every data
%  point. It finds the polynomial of degree p that minimises the sum
%  of squared residuals (least-squares fit).

orders = [2, 3, 4, 5];
colors = [0.4 0.4 0.4; 0.9 0.2 0.2; 0.15 0.4 0.9; 0.1 0.7 0.4];
labels = {'2nd order', '3rd order', '4th order', '5th order'};

figure('Units', 'centimeters', 'Position', [2 8 20 12]);
plot(T, cp, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k'); hold on;

fprintf('\n  Order    R²          Max Error\n');
fprintf('  ─────────────────────────────────\n');

for k = 1:length(orders)
    p     = orders(k);
    coeff = polyfit(T, cp, p);
    cp_fit_fine = polyval(coeff, Ti);
    cp_fit_data = polyval(coeff, T);

    %  R² (coefficient of determination)
    Rsq = R2(cp, cp_fit_data);
    max_err = max(abs(cp - cp_fit_data));

    plot(Ti, cp_fit_fine, '-', 'Color', colors(k,:), 'LineWidth', 2);
    labels{k} = sprintf('%s (R²=%.6f)', labels{k}, Rsq);

    fprintf('  %d       %.6f    %.4e\n', p, Rsq, max_err);
end

xlabel('Temperature [K]');
ylabel('c_p [J g^{-1} K^{-1}]');
title('Polynomial Regression — increasing order', 'FontWeight', 'bold');
legend(['NIST data', labels], 'Location', 'southeast', 'FontSize', 9);

%% ========================================================================
%  6 — Interpolation vs. Regression: side by side
% =========================================================================

figure('Units', 'centimeters', 'Position', [2 8 30 12]);

%  Left: Interpolation (passes through all points)
subplot(1,2,1);
plot(T, cp, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k'); hold on;
plot(Ti, cp_pchip, 'b-', 'LineWidth', 2);
xlabel('Temperature [K]');
ylabel('c_p [J g^{-1} K^{-1}]');
title({'Interpolation'; '(passes through every point)'}, ...
    'FontWeight', 'bold');
legend('Data', 'PCHIP', 'Location', 'southeast');

%  Right: Regression (best-fit smooth curve)
subplot(1,2,2);
coeff_4 = polyfit(T, cp, 4);
cp_reg  = polyval(coeff_4, Ti);
cp_at_T = polyval(coeff_4, T);

plot(T, cp, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k'); hold on;
plot(Ti, cp_reg, 'r-', 'LineWidth', 2);
%  Draw residual lines
for i = 1:length(T)
    plot([T(i) T(i)], [cp(i) cp_at_T(i)], 'r-', 'LineWidth', 1);
end
xlabel('Temperature [K]');
ylabel('c_p [J g^{-1} K^{-1}]');
title({'Regression'; '(minimises squared residuals)'}, ...
    'FontWeight', 'bold');
legend('Data', '4th-order poly', 'Location', 'southeast');

sgtitle('Interpolation vs. Regression', 'FontWeight', 'bold');

%% ========================================================================
%  7 — All properties: regression fits
% =========================================================================

figure('Units', 'centimeters', 'Position', [2 8 36 10]);

prop_data   = {cp, mu, rho};
prop_names  = {'c_p', '\mu', '\rho'};
prop_ylabels = {'c_p [J g^{-1} K^{-1}]', '\mu [Pa \cdot s]', ...
                '\rho [kg m^{-3}]'};

for s = 1:3
    subplot(1,3,s);
    y = prop_data{s};
    plot(T, y, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k'); hold on;

    leg_entries = {'NIST data'};
    for p = 1:5
        coeff = polyfit(T, y, p);
        Rsq   = R2(y, polyval(coeff, T));
        plot(Ti, polyval(coeff, Ti), '-', 'LineWidth', 1.2);
        leg_entries{end+1} = sprintf('p=%d (R²=%.5f)', p, Rsq);
    end

    xlabel('Temperature [K]');
    ylabel(prop_ylabels{s});
    title(sprintf('%s — polynomial fits', prop_names{s}), ...
        'FontWeight', 'bold');
    legend(leg_entries, 'Location', 'best', 'FontSize', 7);
end

sgtitle('Regression fits for all nitrogen properties', ...
    'FontWeight', 'bold');

%% ========================================================================
%  Helper function: R²
% =========================================================================

function Rsq = R2(y, yfit)
% R2 - Coefficient of determination
%
%   Rsq = R2(y, yfit)
%
%   y    : measured data (vector)
%   yfit : fitted values (same size as y)
%   Rsq  : 1 - SSres/SStot  (1 = perfect fit)

    SStot = sum((y - mean(y)).^2);
    SSres = sum((y - yfit).^2);
    Rsq   = 1 - SSres / SStot;
end
