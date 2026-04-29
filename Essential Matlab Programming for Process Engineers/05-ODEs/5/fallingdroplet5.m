%% ========================================================================
%  FALLING DROPLET — with cooling and solidification
%  Lecture: ODEs, part 5/5
%
%  Extends part 4 by adding the latent heat of fusion via the
%  equivalent-heat-capacity method:
%      cp_eff = cp_T + hL / (TL - TS)   inside the mushy zone
%      cp_eff = cp_T                    outside
%
%  This causes the droplet temperature to stall as it crosses the
%  freezing interval, even though energy keeps flowing out of it by
%  convection. The horizontal "plateau" in the cooling curve between
%  T_L and T_S is the visible signature of solidification.
%
%  NOTE — material switch from copper to aluminium alloy:
%  Earlier parts used pure copper, which freezes isothermally at a
%  single temperature (T_S = T_L = 1358 K). The equivalent-cp method
%  needs a non-zero mushy interval to work, so this final lecture
%  switches to a representative aluminium alloy with a real freezing
%  range (~ 548 - 660 deg C).
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

% Droplet material — aluminium alloy (representative AlSi-style values)
p.rho_T = 2700;          % density of droplet           [kg/m^3]
p.cp_T  = 900;           % heat capacity (solid/liquid) [J/(kg*K)]
p.hL    = 381773.5;      % latent heat of fusion        [J/kg]
p.TL    = 660 + 273.15;  % liquidus temperature         [K]
p.TS    = 548 + 273.15;  % solidus temperature          [K]

% Gas (nitrogen) — temperature-dependent properties, anonymous functions.
% (See part 3 for derivation.)

p.eta_G = @(T)  1.77230303e-6 ...
              + 6.27427545e-8  .* T ...
              - 3.47278555e-11 .* T.^2 ...
              + 1.01243201e-14 .* T.^3;

p.cp_G = @(T) 1000 .* ( ...
              - 7.538786635436452e-17 .* T.^5 ...
              + 5.339615845783094e-13 .* T.^4 ...
              - 1.448596667067203e-09 .* T.^3 ...
              + 1.788840017841421e-06 .* T.^2 ...
              - 7.823128158468055e-04 .* T ...
              + 1.150678463409776);

p.rho_G = @(T, P) P .* 0.02801 ./ 8.314 ./ T;

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
T0 = p.TL + 50;          % initial temperature [K]  — superheated liquid
y0 = [u0; x0; T0];

t_span = [0 10];
[T_sol, Y] = ode45(@(t, y) droplet5(t, y, p), t_span, y0);

U   = Y(:, 1);           % velocity column
X   = Y(:, 2);           % distance column
T_d = Y(:, 3);           % droplet-temperature column

fprintf('Final velocity:    %.4f m/s\n', U(end));
fprintf('Total fall:        %.2f m\n',   X(end));
fprintf('Final temperature: %.2f K  (T_inf = %.0f K)\n', T_d(end), p.Tinf);
fprintf('T_L = %.2f K,  T_S = %.2f K\n', p.TL, p.TS);

% How long did the droplet spend in the mushy zone?
in_mushy = (T_d > p.TS) & (T_d < p.TL);
if any(in_mushy)
    t_in   = T_sol(find(in_mushy, 1, 'first'));
    t_out  = T_sol(find(in_mushy, 1, 'last'));
    fprintf('Time in mushy zone: %.3f s  (entered at t = %.3f, left at t = %.3f)\n', ...
            t_out - t_in, t_in, t_out);
end

%% ========================================================================
%  3 — Six views of the same trajectory
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

% --- Cooling over time: highlight the mushy zone ---
subplot(2, 3, 4);
fill_x = [t_span(1), t_span(2), t_span(2), t_span(1)];
fill_y = [p.TS,      p.TS,      p.TL,      p.TL];
patch(fill_x, fill_y, [1.0 0.85 0.6], 'EdgeColor', 'none', ...
      'FaceAlpha', 0.4, 'HandleVisibility', 'off');
hold on;
plot(T_sol, T_d, 'm-');
plot(t_span, [p.Tinf p.Tinf], 'k--');
xlabel('time t [s]');
ylabel('droplet temperature T [K]');
legend('T(t)', sprintf('T_{\\infty} = %.0f K', p.Tinf), ...
       'Location', 'northeast');
text(t_span(2)*0.55, 0.5*(p.TS+p.TL), 'mushy zone', ...
     'FontSize', 10, 'Color', [0.5 0.3 0.0], 'FontAngle', 'italic');

% --- Temperature vs distance: same highlight ---
subplot(2, 3, 5);
fill_x = [0, X(end), X(end), 0];
fill_y = [p.TS, p.TS, p.TL, p.TL];
patch(fill_x, fill_y, [1.0 0.85 0.6], 'EdgeColor', 'none', ...
      'FaceAlpha', 0.4, 'HandleVisibility', 'off');
hold on;
plot(X, T_d, 'm-');
plot([0 X(end)], [p.Tinf p.Tinf], 'k--');
xlabel('distance x [m]');
ylabel('droplet temperature T [K]');

% --- u vs T: state trajectory ---
subplot(2, 3, 6);
fill_x = [p.TS, p.TL, p.TL, p.TS];
fill_y = [0,    0,    max(U)*1.1, max(U)*1.1];
patch(fill_x, fill_y, [1.0 0.85 0.6], 'EdgeColor', 'none', ...
      'FaceAlpha', 0.4, 'HandleVisibility', 'off');
hold on;
plot(T_d, U, 'Color', [0.4 0.2 0.6]);
xlabel('droplet temperature T [K]');
ylabel('velocity u [m/s]');
set(gca, 'XDir', 'reverse');   % T decreases with time, read left-to-right

