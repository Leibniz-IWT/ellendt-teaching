%% ========================================================================
%  DIRECTION FIELD — Falling droplet (cold, constant properties)
%  Lecture: ODEs, part 1/5
%
%  Plots the slope field du/dt(t, u) of the falling-droplet ODE and
%  overlays the numerical solution on top, so students can see the
%  trajectory as the curve tangent to the field at every point.
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
%  2 — Build the direction field
% =========================================================================
%  We sample du/dt on a (t, u) grid. Since du/dt does not actually depend
%  on t for this problem, every column of the field is identical — but
%  we still plot in the (t, u) plane so that the trajectory u(t) can be
%  overlaid naturally.

t = linspace(0,    5, 15);
u = linspace(1e-3, 40, 15);   % start just above zero to avoid Re = 0

[T, U]   = meshgrid(t, u);
dUdt     = droplet(T, U, p);  % vectorised: works on the full meshgrid

% quiver expects (dt, du) components. We want each arrow to display the
% slope du/dt against a unit step in t, so the t-component is 1.
dT = ones(size(dUdt));

%% ========================================================================
%  3 — Overlay the numerical solution
% =========================================================================
%  Integrate the ODE from a tiny initial velocity (avoids the 24/Re
%  singularity at u = 0) and plot the trajectory on top of the field.

u0 = 1e-10;                                  % initial velocity [m/s]
[T_traj, U_traj] = ode45(@(tt, uu) droplet(tt, uu, p), [0 5], u0);

%% ========================================================================
%  4 — Plot
% =========================================================================

figure('Units', 'centimeters', 'Position', [2 8 20 14]);
quiver(T, U, dT, dUdt, 'k'); hold on;
plot(T_traj, U_traj, 'r-', 'LineWidth', 2);

axis([t(1) t(end) u(1) u(end)]);
xlabel('time t [s]');
ylabel('velocity u [m/s]');
title('Direction field of du/dt with numerical solution', ...
      'FontWeight', 'bold');
legend('direction field', 'numerical solution u(t)', ...
       'Location', 'southeast');
