%% ========================================================================
%  FALLING DROPLET — with position tracking
%  Lecture: ODEs, part 2/5
%
%  Extends part 1 by adding the falling distance x as a second state
%  variable. The system is now
%      du/dt = g - drag(u)
%      dx/dt = u
%  Three views of the same solution are produced: u(t), x(t), and the
%  phase portrait u(x).
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

% Gas (nitrogen at 1 bar, 20 deg C)
% (https://www.peacesoftware.de/einigewerte/stickstoff.html)
p.rho_G = 1.1508;        % gas density       [kg/m^3]
p.eta_G = 17.594e-6;     % gas viscosity     [Pa*s]

% Process parameters
p.d = 2e-3;              % droplet diameter  [m]

%% ========================================================================
%  2 — Initial conditions and integration
% =========================================================================

% State vector: y = [u; x]
%   u must not start exactly at zero, otherwise the Stokes-regime drag
%   coefficient c_w = 24/Re becomes 24/0 = Inf. A tiny positive value
%   sidesteps the singularity without affecting the early-time dynamics
%   (gravity dominates for small u anyway).
u0 = 1e-10;              % initial velocity [m/s]
x0 = 0;                  % initial position [m]
y0 = [u0; x0];

t_span = [0 10];
[T, Y] = ode45(@(t, y) droplet2(t, y, p), t_span, y0);

U = Y(:, 1);             % velocity column
X = Y(:, 2);             % distance column

fprintf('Final velocity: %.4f m/s\n', U(end));
fprintf('Total fall:     %.2f m\n',  X(end));

%% ========================================================================
%  3 — Plot all three views side by side
% =========================================================================

figure('Units', 'centimeters', 'Position', [2 8 36 10]);

subplot(1, 3, 1);
plot(T, U, 'r-');
xlabel('time t [s]');
ylabel('velocity u [m/s]');

subplot(1, 3, 2);
plot(T, X, 'b-');
xlabel('time t [s]');
ylabel('distance x [m]');

subplot(1, 3, 3);
plot(X, U, 'k-');
xlabel('distance x [m]');
ylabel('velocity u [m/s]');

