function dydt = droplet2(t, y, p)
% DROPLET2  RHS of the falling-droplet ODE with position tracking.
%
%   dydt = droplet2(t, y, p)
%
%   Two-component state vector:
%       y(1) = u   velocity         [m/s]
%       y(2) = x   falling distance [m]
%
%   Equations of motion:
%       du/dt = g - (3/4) * (rho_G / rho_T) * (1/d) * u^2 * c_w(Re)
%       dx/dt = u
%
%   Drag-coefficient correlation (sphere in fluid):
%       Re <=   1   :  c_w = 24/Re                       (Stokes)
%       1 < Re < 800:  c_w = 24/Re * (1 + 0.15*Re^0.687) (transition)
%       Re >= 800   :  c_w = 0.44                        (plateau)
%
%   Inputs:
%     t : time [s]                — unused, kept for ode45 signature
%     y : state vector [u; x]
%     p : struct with fields
%         .rho_T  droplet density [kg/m^3]
%         .rho_G  gas density     [kg/m^3]
%         .eta_G  gas viscosity   [Pa*s]
%         .d      droplet diameter [m]
%
%   Output:
%     dydt : column vector [du/dt; dx/dt]
%
%   This RHS is intended for ode45-style integrators that pass the state
%   as a column vector. The drag-coefficient block is written branch-free
%   so droplet2 also works element-wise on velocity arrays.

    u = y(1);                       % velocity
    % y(2) = x is not needed on the RHS — equations don't depend on x.

    % Reynolds number
    Re = u * p.d * p.rho_G ./ p.eta_G;

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
    dydt(1) = 9.81 - 0.75 * p.rho_G ./ p.rho_T .* 1 ./ p.d .* u.^2 .* c_w;
    dydt(2) = u;
end
