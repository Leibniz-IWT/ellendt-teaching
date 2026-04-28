%% ========================================================================
%  FALLING DROPLET — with cooling
%  Lecture: ODEs, part 4/5
%
%  Extends part 3 by adding the droplet temperature as a third state
%  variable. The droplet now cools by convection while it falls, with
%  a heat-transfer coefficient computed from the Ranz-Marshall
%  correlation evaluated at the film temperature T_film = (T + Tinf)/2.
%
%  Part 5 will add latent heat / solidification.
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
p.rho_T = 8032;          % density of droplet           [kg/m^3]
p.cp_T  = 382;           % heat capacity of droplet     [J/(kg*K)]

% Gas (nitrogen) — temperature-dependent properties as anonymous functions.
% 'inline' is removed in MATLAB R2024a — anonymous functions are the
% modern equivalent.

% Dynamic viscosity [Pa*s]
p.eta_G = @(T)  1.77230303e-6 ...
              + 6.27427545e-8  .* T ...
              - 3.47278555e-11 .* T.^2 ...
              + 1.01243201e-14 .* T.^3;

% Specific heat at constant pressure [J/(kg*K)]
p.cp_G = @(T) 1000 .* ( ...
              - 7.538786635436452e-17 .* T.^5 ...
              + 5.339615845783094e-13 .* T.^4 ...
              - 1.448596667067203e-09 .* T.^3 ...
              + 1.788840017841421e-06 .* T.^2 ...
              - 7.823128158468055e-04 .* T ...
              + 1.150678463409776);

% Density [kg/m^3] — ideal-gas law for nitrogen, M = 0.02801 kg/mol
p.rho_G = @(T, P) P .* 0.02801 ./ 8.314 ./ T;

% Thermal conductivity [W/(m*K)]
p.lambda_G = @(T)  4.826952276755878e-13 .* T.^3 ...
                 - 8.290391597696784e-09 .* T.^2 ...
                 + 6.727719787886707e-05 .* T ...
                 + 0.006488027452445;

% Process parameters
p.d    = 2e-3;           % droplet diameter             [m]
p.Tinf = 293;            % gas free-stream temperature  [K]

%% ========================================================================
%  2 — Initial conditions and integration
% =========================================================================

% State vector: y = [u; x; T]
% u must not start exactly at zero (Stokes-regime c_w = 24/Re becomes
% Inf at u = 0). A tiny positive value sidesteps the singularity.
u0 = 1e-10;              % initial velocity    [m/s]
x0 = 0;                  % initial position    [m]
T0 = 1200;               % initial temperature [K]
y0 = [u0; x0; T0];

t_span = [0 10];
[T_sol, Y] = ode45(@(t, y) droplet4(t, y, p), t_span, y0);

U = Y(:, 1);             % velocity column
X = Y(:, 2);             % distance column
T_d = Y(:, 3);           % droplet-temperature column

fprintf('Final velocity:    %.4f m/s\n', U(end));
fprintf('Total fall:        %.2f m\n',   X(end));
fprintf('Final temperature: %.2f K\n',   T_d(end));

%% ========================================================================
%  3 — Five views of the same trajectory
% =========================================================================

figure('Units', 'centimeters', 'Position', [2 8 36 18]);

subplot(2, 3, 1);
plot(T_sol, U, 'r-');
xlabel('time t [s]');
ylabel('velocity u [m/s]');

subplot(2, 3, 2);
plot(T_sol, X, 'b-');
xlabel('time t [s]');
ylabel('distance x [m]');

subplot(2, 3, 3);
plot(X, U, 'k-');
xlabel('distance x [m]');
ylabel('velocity u [m/s]');

subplot(2, 3, 4);
plot(T_sol, T_d, 'm-'); hold on;
plot(t_span, [p.Tinf p.Tinf], 'k--');
xlabel('time t [s]');
ylabel('droplet temperature T [K]');
legend('T(t)', sprintf('T_{\\infty} = %.0f K', p.Tinf), ...
       'Location', 'northeast');

subplot(2, 3, 5);
plot(X, T_d, 'm-'); hold on;
plot([X(1) X(end)], [p.Tinf p.Tinf], 'k--');
xlabel('distance x [m]');
ylabel('droplet temperature T [K]');

% Sixth panel: u vs T — useful summary of the coupled dynamics
subplot(2, 3, 6);
plot(T_d, U, 'Color', [0.4 0.2 0.6]);
xlabel('droplet temperature T [K]');
ylabel('velocity u [m/s]');
set(gca, 'XDir', 'reverse');   % T decreases with time, read left-to-right
