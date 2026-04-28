%% ========================================================================
%  FALLING DROPLET — temperature-dependent gas properties
%  Lecture: ODEs, part 3/5
%
%  Extends part 2 by replacing the *constant* gas properties with
%  temperature-dependent correlations:
%      rho_G(T, P) = ideal-gas law
%      eta_G(T)    = polynomial fit of NIST data
%      cp_G(T)     = polynomial fit of NIST data   (used in later parts)
%      lambda_G(T) = polynomial fit of NIST data   (used in later parts)
%
%  The gas temperature is still held fixed at 293 K in this lecture; the
%  property functions are introduced now so that later parts can simply
%  evaluate them at a varying gas temperature.
%
%  Author: Dr. Nils Ellendt
% =========================================================================

clear; close all; clc;

%% --- Global figure settings ---
set(0, 'DefaultAxesFontSize',   13);
set(0, 'DefaultAxesFontName',   'Times New Roman');
set(0, 'DefaultLineLineWidth',  1.5);
set(0, 'DefaultAxesBox',        'on');
set(0, 'DefaultFigureColor',    'w');

%% ========================================================================
%  1 — Parameters
% =========================================================================

% Droplet material (copper)
p.rho_T = 8032;          % density of droplet [kg/m^3]

% Gas (nitrogen) — temperature-dependent properties as anonymous functions.
% Polynomials are fits to NIST WebBook data; coefficients in SI units.
% Note: 'inline' is removed in MATLAB R2024a — use anonymous functions.

% Dynamic viscosity [Pa*s]
p.eta_G = @(T)  1.77230303e-6 ...
              + 6.27427545e-8  .* T ...
              - 3.47278555e-11 .* T.^2 ...
              + 1.01243201e-14 .* T.^3;

% Specific heat at constant pressure [J/(kg*K)]  (unused in this part,
% loaded for the cooling lecture)
p.cp_G = @(T) 1000 .* ( ...
              - 7.538786635436452e-17 .* T.^5 ...
              + 5.339615845783094e-13 .* T.^4 ...
              - 1.448596667067203e-09 .* T.^3 ...
              + 1.788840017841421e-06 .* T.^2 ...
              - 7.823128158468055e-04 .* T ...
              + 1.150678463409776);

% Density [kg/m^3] — ideal-gas law for nitrogen, M = 0.02801 kg/mol
p.rho_G = @(T, P) P .* 0.02801 ./ 8.314 ./ T;

% Thermal conductivity [W/(m*K)]  (also for later parts)
p.lambda_G = @(T)  4.826952276755878e-13 .* T.^3 ...
                 - 8.290391597696784e-09 .* T.^2 ...
                 + 6.727719787886707e-05 .* T ...
                 + 0.006488027452445;

% Process parameters
p.d = 2e-3;              % droplet diameter [m]

%% ========================================================================
%  2 — Initial conditions and integration
% =========================================================================

% State vector: y = [u; x]
% u must not start exactly at zero (Stokes-regime c_w = 24/Re becomes
% Inf at u = 0). A tiny positive value sidesteps the singularity.
u0 = 1e-10;              % initial velocity [m/s]
x0 = 0;                  % initial position [m]
y0 = [u0; x0];

t_span = [0 10];
[T_sol, Y] = ode45(@(t, y) droplet3(t, y, p), t_span, y0);

U = Y(:, 1);             % velocity column
X = Y(:, 2);             % distance column

fprintf('Final velocity: %.4f m/s\n', U(end));
fprintf('Total fall:     %.2f m\n',   X(end));

%% ========================================================================
%  3 — Plot all three views side by side
% =========================================================================

figure('Units', 'centimeters', 'Position', [2 8 36 10]);

subplot(1, 3, 1);
plot(T_sol, U, 'r-');
xlabel('time t [s]');
ylabel('velocity u [m/s]');

subplot(1, 3, 2);
plot(T_sol, X, 'b-');
xlabel('time t [s]');
ylabel('distance x [m]');

subplot(1, 3, 3);
plot(X, U, 'k-');
xlabel('distance x [m]');
ylabel('velocity u [m/s]');

%% ========================================================================
%  4 — Show the property functions over a range of temperatures
% =========================================================================
%  Even though the integrator currently uses only T = 293 K, plotting
%  the property functions over a wide range is a useful sanity check
%  before lectures 4 and 5 turn the gas temperature into a state.

T_range = linspace(200, 2000, 200);

figure('Units', 'centimeters', 'Position', [2 8 36 10]);

subplot(1, 4, 1);
plot(T_range, p.rho_G(T_range, 1e5), 'k-');
xlabel('T [K]');  ylabel('\rho_G [kg/m^3]');

subplot(1, 4, 2);
plot(T_range, p.eta_G(T_range), 'k-');
xlabel('T [K]');  ylabel('\eta_G [Pa s]');

subplot(1, 4, 3);
plot(T_range, p.cp_G(T_range), 'k-');
xlabel('T [K]');  ylabel('c_{p,G} [J/(kg K)]');

subplot(1, 4, 4);
plot(T_range, p.lambda_G(T_range), 'k-');
xlabel('T [K]');  ylabel('\lambda_G [W/(m K)]');