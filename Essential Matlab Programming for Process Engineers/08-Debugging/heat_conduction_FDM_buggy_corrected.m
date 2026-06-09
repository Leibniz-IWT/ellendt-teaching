%% 2D Heat Conduction in a Square Plate”FDM Method
%  316L stainless steel, 0.1 x 0.1 m
%  Internal heat source Q, four walls at different temperatures
%
%  NOTE: this code contains deliberate errors, your task is to find and
%  correct the errors

clear; close all; clc

%% Material and source
k  = 16;      % thermal conductivity  [W/(m*K)]
Q  = 5e5;      % heat source           [W/m^3]

%% Geometry
Lx = 0.1;
Ly = 0.1;

%% Grid
Nx = 41;
Ny = 41;
dx = Lx / (Nx-1);
dy = Ly / (Ny-1);
x  = linspace(0, Lx, Nx);
y  = linspace(0, Ly, Ny);

%% Wall temperatures  [Â°C]
T_left   = 100;
T_right  = 200;
T_bottom = 300;
T_top    = 400;

%% Initialise and apply boundary conditions
T = zeros(Nx, Ny);

T(1,  :) = T_left; % left wall
T(Nx, :) = T_right; % right wall    
T(:,  1) = T_bottom; % bottom wall
T(:, Ny) = T_top; % top wall

%% Iterative solution
tol     = 1e-6;
maxIter = 200000;
rel_res = inf;
iter    = 0;

while rel_res > tol && iter < maxIter
    T_old = T;

    for i = 2:Nx-1
        for j = 2:Ny-1
            T(i,j) = ( (T(i+1,j) + T(i-1,j)) / dx^2 ...
                     + (T(i,j+1) + T(i,j-1)) / dy^2 ...
                     +  Q/k ) ...
                   / (2/dx^2 + 2/dy^2);
        end
    end

    T(1,  :) = T_left; % left wall
    T(Nx, :) = T_right; % right wall    
    T(:,  1) = T_bottom; % bottom wall
    T(:, Ny) = T_top; % top wall

    rel_res = max(max(abs(T - T_old))) / max(max(abs(T)));
    iter    = iter + 1;
end

fprintf('Iterations : %d\n', iter);
fprintf('Rel. res.  : %.2e\n', rel_res);
fprintf('T_min = %.1f C,  T_max = %.1f C\n', min(T(:)), max(T(:)));

%% Plot
[X, Y] = meshgrid(x, y);

figure('Position', [100 100 820 560])
contourf(X, Y, T', 40, 'LineColor', 'none')
xlabel('x / m')
ylabel('y / m')
title('Temperature field 316L stainless steel plate')
cb = colorbar;
cb.Label.String = 'Temperature / °C';
axis equal tight
