clear all

%% find terminal velocity of falling sphere

%% property structure
sphere_prop.d=100e-6;
sphere_prop.nu=15.3e-6;
sphere_prop.rhog=1.19;
sphere_prop.rhos=7800;

%% find terminal velocities for sphere diameters from 100 µm (10^-4 m) to 10 mm (10^-2 m)

% use logspace for velocity vector
d_sphere=logspace(-6,-3,100);
u_term=zeros(size(d_sphere));

i=0;
for d=d_sphere,
        i=i+1;
        sphere_prop.d=d;
        u0=[1e-8 100];
        u_term(i)=fzero(@(u)terminal(u,sphere_prop),u0)
end

Re_d=u_term.*d_sphere/sphere_prop.nu;

loglog(d_sphere,u_term)
xlabel 'sphere diameter / m';
ylabel 'terminal velocity / m/s'
grid on
figure
loglog(Re_d,u_term)
xlabel 'Reynolds Number / -';
ylabel 'terminal velocity / m/s'
grid on