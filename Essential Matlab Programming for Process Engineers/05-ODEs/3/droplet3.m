function dydt = droplet3(t, y, p)
% DROPLET3  RHS of the falling-droplet ODE with T-dependent gas properties.
%
%   dydt = droplet3(t, y, p)
%
%   Two-component state vector (same as DROPLET2):
%       y(1) = u   velocity         [m/s]
%       y(2) = x   falling distance [m]
%
%   Equations of motion:
%       du/dt = g - (3/4) * (rho_G / rho_T) * (1/d) * u^2 * c_w(Re)
%       dx/dt = u
%
%   The gas density and viscosity are now *functions of temperature*,
%   accessed through the function handles p.rho_G(T, P) and p.eta_G(T).
%   In this lecture the gas temperature is held fixed (T_gas = 293 K)
%   and the gas pressure at 1 atm. In subsequent lectures the droplet
%   temperature will become a third state variable.
%
%   Inputs:
%     t : time [s]                — unused, kept for ode45 signature
%     y : state vector [u; x]
%     p : struct with fields
%         .rho_T   droplet density           [kg/m^3]   (scalar)
%         .rho_G   gas density function      @(T, P)    [kg/m^3]
%         .eta_G   gas viscosity function    @(T)       [Pa*s]
%         .cp_G    gas heat capacity         @(T)       [J/(kg*K)]   (unused here)
%         .lambda_G gas thermal conductivity @(T)       [W/(m*K)]    (unused here)
%         .d       droplet diameter          [m]
%
%   Output:
%     dydt : column vector [du/dt; dx/dt]

    u = y(1);                       % velocity

    % Gas-temperature placeholder. In later parts of the lecture
    % series this will become a third state variable y(3).
    T_gas = 293;                    % [K]
    P_gas = 1e5;                    % [Pa]

    % Cache property evaluations (called twice if not cached)
    rho_G = p.rho_G(T_gas, P_gas);
    eta_G = p.eta_G(T_gas);

    % Reynolds number
    Re = u * p.d * rho_G ./ eta_G;

    % Drag coefficient — element-wise selection by regime
    c_w        = zeros(size(Re));
    stokes     = (Re <= 1) & (Re > 0);
    transition = (Re >  1) & (Re < 800);
    plateau    =  Re >= 800;

    c_w(stokes)     = 24 ./ Re(stokes);
    c_w(transition) = 24 ./ Re(transition) .* (1 + 0.15 * Re(transition).^0.687);
    c_w(plateau)    = 0.44;
    % Note: Re == 0 leaves c_w = 0, giving zero drag force (drag ~ u^2 c_w),
    %       so the singularity 24/0 is sidestepped without a special case.

    % Assemble the RHS
    dydt    = zeros(2, 1);
    dydt(1) = 9.81 - 0.75 * rho_G ./ p.rho_T .* 1 ./ p.d .* u.^2 .* c_w;
    dydt(2) = u;
end
