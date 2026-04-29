function dydt = droplet5(t, y, p)
% DROPLET5  RHS of the falling-droplet ODE with cooling and solidification.
%
%   dydt = droplet5(t, y, p)
%
%   Three-component state vector:
%       y(1) = u   velocity            [m/s]
%       y(2) = x   falling distance    [m]
%       y(3) = T   droplet temperature [K]
%
%   Equations of motion:
%       du/dt = g - (3/4) (rho_G(T)/rho_T) (1/d) u^2 c_w(Re_drag)
%       dx/dt = u
%       dT/dt = -(6 alpha / (d rho_T cp_eff)) (T - T_inf)
%
%   Latent heat is incorporated through an *equivalent heat capacity*:
%
%       cp_eff(T) = cp_T                       outside [T_S, T_L]
%       cp_eff(T) = cp_T + h_L / (T_L - T_S)   inside  [T_S, T_L]
%
%   This is a standard simplified approach for solidification: the
%   latent heat h_L is smeared evenly across the mushy interval, so
%   that integrating cp_eff dT from T_S to T_L releases exactly h_L
%   of energy. The droplet temperature stalls in the freezing range
%   while energy continues to flow out via convection.
%
%   Inputs:
%     t : time [s]                — unused, kept for ode45 signature
%     y : state vector [u; x; T]
%     p : struct with fields
%         .rho_T    droplet density           [kg/m^3]
%         .cp_T     droplet heat capacity     [J/(kg*K)]   (solid/liquid)
%         .hL       latent heat of fusion     [J/kg]
%         .TS       solidus temperature       [K]
%         .TL       liquidus temperature      [K]
%         .rho_G    gas density function      @(T, P)
%         .eta_G    gas viscosity function    @(T)
%         .cp_G     gas heat capacity         @(T)
%         .lambda_G gas thermal conductivity  @(T)
%         .d        droplet diameter          [m]
%         .Tinf     gas free-stream temperature [K]
%
%   Output:
%     dydt : column vector [du/dt; dx/dt; dT/dt]

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

    %% --- Effective heat capacity (equivalent-cp method) ---
    if (T > p.TS) && (T < p.TL)
        % Inside the mushy zone: smear h_L across the freezing interval
        cp_eff = p.cp_T + p.hL / (p.TL - p.TS);
    else
        % Pure liquid (T >= TL) or pure solid (T <= TS)
        cp_eff = p.cp_T;
    end

    %% --- Assemble the RHS ---
    dydt    = zeros(3, 1);
    dydt(1) = 9.81 - 0.75 * rho_G_drag ./ p.rho_T .* 1 ./ p.d .* u.^2 .* c_w;
    dydt(2) = u;
    dydt(3) = -6 * alpha / (p.d * p.rho_T * cp_eff) * (T - p.Tinf);
end
