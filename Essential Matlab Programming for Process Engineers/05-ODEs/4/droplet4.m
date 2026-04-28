function dydt = droplet4(t, y, p)
% DROPLET4  RHS of the falling-droplet ODE with cooling.
%
%   dydt = droplet4(t, y, p)
%
%   Three-component state vector:
%       y(1) = u   velocity            [m/s]
%       y(2) = x   falling distance    [m]
%       y(3) = T   droplet temperature [K]
%
%   Equations of motion:
%       du/dt = g - (3/4) (rho_G(T)/rho_T) (1/d) u^2 c_w(Re_drag)
%       dx/dt = u
%       dT/dt = -(6 alpha / (d rho_T cp_T)) (T - T_inf)
%
%   The factor 6/d is the surface-area-to-volume ratio for a sphere,
%   A/V = (pi d^2)/(pi d^3 / 6) = 6/d.
%
%   Heat transfer coefficient alpha comes from the Ranz-Marshall
%   correlation for a sphere in convective flow:
%       Nu = 2 + 0.6 Re_heat^(1/2) Pr^(1/3)        [Ranz & Marshall, 1952]
%       alpha = Nu * lambda_G / d
%
%   Two distinct Reynolds numbers appear in this problem:
%     Re_drag : computed at the local gas state (T, P) used for momentum
%     Re_heat : computed at the film temperature T_film = (T + T_inf)/2,
%               which is the appropriate average for heat-transfer
%               correlations of a hot sphere in a cold gas.
%
%   Inputs:
%     t : time [s]                — unused, kept for ode45 signature
%     y : state vector [u; x; T]
%     p : struct with fields
%         .rho_T    droplet density           [kg/m^3]
%         .cp_T     droplet heat capacity     [J/(kg*K)]
%         .rho_G    gas density function      @(T, P)
%         .eta_G    gas viscosity function    @(T)
%         .cp_G     gas heat capacity         @(T)
%         .lambda_G gas thermal conductivity  @(T)
%         .d        droplet diameter          [m]
%         .Tinf     gas free-stream temperature [K]
%
%   Output:
%     dydt : column vector [du/dt; dx/dt; dT/dt]
%
%   Note: this model assumes the droplet stays liquid throughout the
%   integration window. Latent heat / solidification is added in
%   lecture part 5.

    u = y(1);                       % velocity
    T = y(3);                       % droplet temperature
    P = 1e5;                        % gas pressure [Pa]

    %% --- Drag block: properties at droplet/gas interface T ---
    rho_G_drag = p.rho_G(T, P);
    eta_G_drag = p.eta_G(T);

    Re_drag = u * p.d * rho_G_drag ./ eta_G_drag;

    % Drag coefficient — element-wise selection by regime
    c_w        = zeros(size(Re_drag));
    stokes     = (Re_drag <= 1) & (Re_drag > 0);
    transition = (Re_drag >  1) & (Re_drag < 800);
    plateau    =  Re_drag >= 800;

    c_w(stokes)     = 24 ./ Re_drag(stokes);
    c_w(transition) = 24 ./ Re_drag(transition) .* (1 + 0.15 * Re_drag(transition).^0.687);
    c_w(plateau)    = 0.44;
    % Re == 0 leaves c_w = 0, sidestepping the 24/0 singularity.

    %% --- Heat-transfer block: properties at film temperature ---
    T_film     = 0.5 * (T + p.Tinf);
    rho_G_film = p.rho_G(T_film, P);
    eta_G_film = p.eta_G(T_film);
    cp_G_film  = p.cp_G(T_film);
    lam_G_film = p.lambda_G(T_film);

    Re_heat = u * p.d * rho_G_film / eta_G_film;
    Pr      = eta_G_film * cp_G_film / lam_G_film;

    % Ranz-Marshall correlation for a sphere
    Nu    = 2 + 0.6 * Re_heat^0.5 * Pr^(1/3);
    alpha = Nu * lam_G_film / p.d;

    %% --- Assemble the RHS ---
    dydt    = zeros(3, 1);
    dydt(1) = 9.81 - 0.75 * rho_G_drag ./ p.rho_T .* 1 ./ p.d .* u.^2 .* c_w;
    dydt(2) = u;
    dydt(3) = -6 * alpha / (p.d * p.rho_T * p.cp_T) * (T - p.Tinf);
end
