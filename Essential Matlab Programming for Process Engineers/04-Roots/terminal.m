function du_dt = terminal(u, p)
% TERMINAL  Right-hand side of the falling sphere ODE.
%
%   du_dt = TERMINAL(u, p)
%
%   Computes the acceleration of a sphere falling through a fluid:
%
%       du/dt = g - (3/4) * (rho_g / rho_s) * (1/d) * u^2 * C_d
%
%   At terminal velocity, du/dt = 0  →  this is a ROOT FINDING problem.
%
%   Inputs
%   ------
%   u : double
%       Current velocity [m/s]
%   p : struct with fields
%       .d    – sphere diameter [m]
%       .nu   – kinematic viscosity of the fluid [m²/s]
%       .rhog – fluid density [kg/m³]
%       .rhos – sphere density [kg/m³]
%
%   Output
%   ------
%   du_dt : double
%       Acceleration [m/s²]
%
%   Drag correlation: Schiller–Naumann (valid for Re < 1000)
%       C_d = (24/Re) * (1 + 0.15 * Re^0.687)

%  Reynolds number
Re = u * p.d / p.nu;

%  Drag coefficient (Schiller-Naumann)
Cd = 24 ./ Re .* (1 + 0.15 * Re.^0.687);

%  Equation of motion: gravity – drag
du_dt = 9.81 - 0.75 * (p.rhog / p.rhos) / p.d * u.^2 .* Cd;

end
