%% ========================================================================
%  1D UNSTEADY HEAT CONDUCTION IN A SPHERE
%  Transient PDE solution via pdepe with convective surface cooling
%  ========================================================================
%
%  Problem:
%    A solid sphere of radius R is initially at uniform temperature T_0
%    and is cooled by convection to an ambient T_inf.
%
%      rho*cp * dT/dt = (1/r^2) * d/dr ( r^2 * k * dT/dr )       (m = 2)
%
%    Boundary conditions:
%      r = 0 :  symmetry        (handled automatically by pdepe for m=2)
%      r = R : -k*dT/dr = h*(T - T_inf)     (Robin / convective)
%
%    Initial condition:
%      T(r,0) = T_0
%
%    This is the canonical case for introducing the Biot and Fourier
%    numbers (Bi = h*R/k, Fo = a_th*t/R^2).
%
%  pdepe canonical form:
%      c(x,t,u,du/dx) * du/dt  =  x^(-m) * d/dx( x^m * f(x,t,u,du/dx) )  +  s

clear; close all; clc

%% 1) Plot defaults (consistent style across all course scripts)
set(0, 'DefaultLineLineWidth',  1.5, ...
       'DefaultAxesFontSize',   11,  ...
       'DefaultAxesLineWidth',  1.0, ...
       'DefaultAxesBox',        'on', ...
       'DefaultAxesXGrid',      'on', ...
       'DefaultAxesYGrid',      'on', ...
       'DefaultFigureColor',    'w');

%% 2) Geometry and discretization
R     = 5e-3;       % sphere radius                   [m]
t_end = 5;          % total simulation time           [s]
Nx    = 101;        % number of radial nodes
Nt    = 100;        % number of time steps

x = linspace(0, R,     Nx);   % radial grid
t = linspace(0, t_end, Nt);   % time grid

% indices for plotting:  (centre, mid-radius, surface)  and  (start, mid, end)
ix = [1, round((Nx+1)/2), Nx];   % -> [1  51 101]
it = [1, round( Nt   /2), Nt];   % -> [1  50 100]   (NOT [1 13 25] !)

%% 3) Solve the PDE
m   = 2;                                                  % spherical coordinates
SOL = pdepe(m, @HeatPDE, @HeatPDE_IC, @HeatPDE_BC, x, t); % SOL(it, ix) = T

%% 4) Diagnostic summary  (read parameters from the local functions)
[rho, cp, k]     = local_get_props();
[alpha_h, T_inf] = local_get_bc();
T_0              = HeatPDE_IC(0, 0, 0, 0);

a_th = k / (rho * cp);          % thermal diffusivity  [m^2/s]
Fo   = a_th * t_end / R^2;      % Fourier number at t_end
Bi   = alpha_h * R / k;         % Biot number

fprintf('============================================\n')
fprintf(' Sphere heat conduction  --  summary        \n')
fprintf('============================================\n')
fprintf(' Radius R           = %.3e m\n',         R)
fprintf(' Density   rho      = %.0f kg/m^3\n',    rho)
fprintf(' Heat cap. cp       = %.0f J/(kg*K)\n',  cp)
fprintf(' Conductivity k     = %.3f W/(m*K)\n',   k)
fprintf(' Diffusivity a_th   = %.3e m^2/s\n',     a_th)
fprintf(' Initial temp T_0   = %.0f K\n',         T_0)
fprintf(' Ambient temp T_inf = %.0f K\n',         T_inf)
fprintf(' Heat-transfer h    = %.0f W/(m^2*K)\n', alpha_h)
fprintf(' ------------------------------------------\n')
fprintf(' Biot number    Bi  = %6.3f   (Bi << 1 -> lumped capacitance valid)\n', Bi)
fprintf(' Fourier number Fo  = %6.3f   (Fo >~ 0.2 -> diffusion has reached centre)\n', Fo)
fprintf(' Final centre  temp = %.1f K\n', SOL(end, 1))
fprintf(' Final surface temp = %.1f K\n', SOL(end, end))
fprintf('============================================\n\n')

%% 5) Surface plot of the full field  T(r, t)
[Xg, Tg] = meshgrid(x, t);

figure('Name','Temperature field T(r,t)','Position',[100 100 720 520])
surf(Xg, Tg, SOL)
shading interp
view(0, 90)
axis tight
xlabel('r / m')
ylabel('t / s')
title('Temperature field T(r, t)')
cb = colorbar('horiz');
cb.Label.String = 'Temperatur / K';

%% 6) Temperature vs time at fixed radii
figure('Name','T(t) at fixed r','Position',[100 100 720 520])
plot(t, SOL(:, ix(1)), 'k', ...
     t, SOL(:, ix(2)), 'r', ...
     t, SOL(:, ix(3)), 'b')
xlabel('t / s')
ylabel('T / K')
title('Temperature evolution at fixed radii')
legend('r^* = 0  (centre)', ...
       'r^* = 0.5', ...
       'r^* = 1  (surface)', ...
       'Location','northeast')

%% 7) Temperature profile vs radius at fixed times
figure('Name','T(r) at fixed t','Position',[100 100 720 520])
plot(x, SOL(it(1), :), 'k', ...
     x, SOL(it(2), :), 'r', ...
     x, SOL(it(3), :), 'b')
xlabel('r / m')
ylabel('T / K')
title('Temperature profile at fixed times')
legend(sprintf('t^* = 0    (t = %.2f s)', t(it(1))), ...
       sprintf('t^* = 0.5  (t = %.2f s)', t(it(2))), ...
       sprintf('t^* = 1    (t = %.2f s)', t(it(3))), ...
       'Location','northeast')

%% 8) Cross-sectional slice through the sphere at t* = 0.5
T_mid       = SOL(it(2), :);                  % profile at mid-time   [1 x Nx]
phi         = linspace(0, 2*pi, 100);         % rotation angle
[PHI, RR]   = meshgrid(phi, x);               % [Nx x Nphi]
T_slice     = repmat(T_mid, numel(phi), 1).'; % stack along phi  [Nx x Nphi]
[Xc, Yc]    = pol2cart(PHI, RR);

figure('Name','Sphere cross-section','Position',[100 100 620 620])
surf(Xc, Yc, T_slice)
view(0, 90)
shading interp
colormap hot
axis equal tight
xlabel('x / m')
ylabel('y / m')
title(sprintf('Cross-section at t = %.2f s', t(it(2))))
cb = colorbar;
cb.Label.String = 'Temperatur / K';


%% ========================================================================
%  LOCAL FUNCTIONS
%  (kept side-by-side with the script so the whole problem lives in one
%   file -- pdepe accepts handles to local functions just fine)
%  ========================================================================

function [c, f, s] = HeatPDE(~, ~, ~, dudx)
%HEATPDE  pdepe coefficients for 1D unsteady heat conduction in a sphere.
%   Form:  c * du/dt = x^(-m) * d/dx( x^m * f ) + s
    [rho, cp, k] = local_get_props();
    c = rho * cp;
    f = k * dudx;
    s = 0;
end


function u0 = HeatPDE_IC(~, ~, ~, ~)
%HEATPDE_IC  initial condition (uniform temperature).
    u0 = 800;       % K
end


function [pl, ql, pr, qr] = HeatPDE_BC(~, ~, ~, ur, ~)
%HEATPDE_BC  boundary conditions for pdepe.
%   Form on each side:  p(x,t,u) + q(x,t) * f = 0
%   Left  (r = 0):  symmetry -- ignored by pdepe because m = 2
%   Right (r = R):  -k*dT/dr = h*(T - T_inf)
%                   ->  p_r = h*(u_r - T_inf),   q_r = 1
    [alpha_h, T_inf] = local_get_bc();
    pl = 0;   ql = 0;                       % ignored when m = 2
    pr = alpha_h * (ur - T_inf);
    qr = 1;
end


function [rho, cp, k] = local_get_props()
%LOCAL_GET_PROPS  material properties (steel-like body; k deliberately
%   reduced so the transient fits inside the chosen simulation window).
    rho = 7800;     % density            [kg/m^3]
    cp  = 465;      % heat capacity      [J/(kg*K)]
    k   = 20;       % conductivity       [W/(m*K)]
end


function [alpha_h, T_inf] = local_get_bc()
%LOCAL_GET_BC  convective boundary parameters.
    alpha_h = 500;    % heat-transfer coefficient  [W/(m^2*K)]
    T_inf   = 293;    % ambient temperature        [K]
end
