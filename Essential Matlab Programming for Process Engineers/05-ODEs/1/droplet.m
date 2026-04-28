function dudt = droplet(t, u, p)
% DROPLET  Right-hand side of the falling-droplet ODE.
%
%   dudt = droplet(t, u, p)
%
%   Computes  du/dt = g - (3/4) * (rho_G / rho_T) * (1/d) * u^2 * c_w(Re)
%
%   where the drag coefficient c_w follows the standard three-regime
%   correlation for spheres in a fluid:
%       Re <=   1   :  c_w = 24/Re                      (Stokes)
%       1 < Re < 800:  c_w = 24/Re * (1 + 0.15*Re^0.687) (transition)
%       Re >= 800   :  c_w = 0.44                       (plateau)
%
%   Inputs:
%     t : time [s]                — unused, kept for ode45 signature
%     u : velocity [m/s]          — scalar OR array (vectorised over u)
%     p : struct with fields
%         .rho_T  droplet density [kg/m^3]
%         .rho_G  gas density     [kg/m^3]
%         .eta_G  gas viscosity   [Pa*s]
%         .d      droplet diameter [m]
%
%   Output:
%     dudt : time derivative du/dt [m/s^2], same size as u
%
%   The function is fully vectorised over u so it can be evaluated on a
%   meshgrid for direction-field plotting, and called scalar-wise by
%   ode45 / fzero with no changes.

    % Reynolds number (element-wise)
    Re = u * p.d * p.rho_G ./ p.eta_G;

    % Drag coefficient — element-wise selection by regime
    c_w        = zeros(size(Re));
    stokes     = (Re <= 1) & (Re > 0);
    transition = (Re >  1) & (Re < 800);
    plateau    =  Re >= 800;

    c_w(stokes)     = 24 ./ Re(stokes);
    c_w(transition) = 24 ./ Re(transition) .* (1 + 0.15 * Re(transition).^0.687);
    c_w(plateau)    = 0.44;
    % Note: Re == 0 leaves c_w = 0, which gives the correct zero drag
    %       force (drag ~ u^2 * c_w), avoiding the 24/0 = Inf singularity.

    % Equation of motion: gravity minus drag deceleration
    dudt = 9.81 - 0.75 * p.rho_G ./ p.rho_T .* 1 ./ p.d .* u.^2 .* c_w;
end
