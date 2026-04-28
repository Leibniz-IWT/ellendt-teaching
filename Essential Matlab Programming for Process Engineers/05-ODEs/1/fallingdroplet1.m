%% ========================================================================
%  FALLING DROPLET — Cold, constant properties
%  Lecture: ODEs, part 1/4
%
%  Solves the falling-droplet equation of motion
%      du/dt = g - (3/4) * (rho_G / rho_T) * (1/d) * u^2 * c_w(Re)
%  for a copper droplet falling through nitrogen, and compares the
%  numerical trajectory to the terminal velocity (du/dt = 0).
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
%  2 — Initial and terminal conditions
% =========================================================================

% Initial velocity must not be exactly zero, because the Stokes-regime
% drag coefficient c_w = 24/Re becomes 24/0 = Inf at u = 0. A tiny
% positive starting value sidesteps the singularity without affecting
% the early-time dynamics (gravity dominates for small u anyway).
u0 = 1e-10;              % initial velocity [m/s]

% Terminal velocity = root of du/dt(u) = 0.
% The initial guess for fzero should be in the order of magnitude of the
% expected terminal velocity. For copper (~ 8000 kg/m^3) in nitrogen,
% u_term lands around 20 m/s; for other materials/gases, scale this
% guess accordingly.
u_guess = 20;            % rough guess [m/s]
u_term  = fzero(@(uu) droplet(0, uu, p), u_guess);

fprintf('Terminal velocity: %.4f m/s\n', u_term);

%% ========================================================================
%  3 — Integrate the ODE
% =========================================================================

t_span = [0 10];
[T, U] = ode45(@(t, u) droplet(t, u, p), t_span, u0);

%% ========================================================================
%  4 — Plot
% =========================================================================

figure('Units', 'centimeters', 'Position', [2 8 20 12]);
plot(t_span, [u_term u_term], 'k--');           hold on;
plot(T,      U,                'r-');
xlabel('time t [s]');
ylabel('velocity u [m/s]');
legend(sprintf('terminal velocity = %.2f m/s', u_term), ...
       'numerical solution u(t)',                   ...
       'Location', 'southeast');
