%% ========================================================================
%  WORKING WITH PARTICLE SIZE DISTRIBUTIONS
%  Reading, processing, visualising and exporting PSD data
%  ========================================================================
%
%  This script demonstrates a complete PSD workflow:
%    1. Import measurement data from a CSV file
%    2. Compute the cumulative distribution Q3 by numerical integration
%    3. Extract characteristic diameters (d10, d16, d50, d84, d90) via
%       inverse interpolation
%    4. Compute statistical descriptors (geometric std. dev., span)
%    5. Visualise density and cumulative distribution together
%    6. Annotate and export the result as a self-documenting JSON file
%
%  Data file:  psd.csv   (two header lines, then: x/m, q3/1/um)
%  Helper:     readjson.m   (reads back the exported JSON for verification)
%
%  Author:  Prof. Nils Ellendt, Leibniz-IWT, University of Bremen
%  Course:  Essential MATLAB Programming for Process Engineers
%  ========================================================================

clear; close all; clc

%% 1) Plot defaults (consistent style across all course scripts)
set(0, 'DefaultLineLineWidth',  1.5,  ...
       'DefaultAxesFontSize',   11,   ...
       'DefaultAxesLineWidth',  1.0,  ...
       'DefaultAxesBox',        'on', ...
       'DefaultAxesXGrid',      'on', ...
       'DefaultAxesYGrid',      'on', ...
       'DefaultFigureColor',    'w');

%% 2) Import data
%  CSV layout: two comment lines, then columns  x [m]  |  q3 [1/um]
%  readmatrix replaces the deprecated dlmread.
A = readmatrix('psd.csv', 'NumHeaderLines', 2);

%  Store in a struct and convert x from metres to micrometres so that
%  units are consistent with q3 [1/um]:  q3 * dx [um] is dimensionless.
psd.x  = A(:, 1) * 1e6;   % particle diameter centre  [um]
psd.q3 = A(:, 2);          % volume density distribution  [1/um]

%% 3) Compute cumulative distribution Q3
%  The bin width (constant spacing checked first):
psd.dx = psd.x(2) - psd.x(1);   % [um]

%  Q3(x) = integral_0^x q3(x') dx'  -- rectangle rule (right edge):
psd.Q3 = cumsum(psd.q3 * psd.dx);

%  Normalise to 1 (compensates for discretisation / truncation errors):
psd.Q3 = psd.Q3 / max(psd.Q3);

%  Q3 belongs to the upper edge of each bin, not the bin centre:
psd.x_upper = psd.x + 0.5 * psd.dx;   % [um]

%% 4) Characteristic diameters by inverse interpolation
%  dx = Q3^-1(p)  means: find the particle size at which Q3 equals p.
psd.d10 = interp1(psd.Q3, psd.x_upper, 0.10);
psd.d16 = interp1(psd.Q3, psd.x_upper, 0.16);
psd.d50 = interp1(psd.Q3, psd.x_upper, 0.50);
psd.d84 = interp1(psd.Q3, psd.x_upper, 0.84);
psd.d90 = interp1(psd.Q3, psd.x_upper, 0.90);

%% 5) Statistical descriptors
%  Geometric standard deviation (two-sided estimate from Q3):
psd.sigma_g1 = psd.d50 / psd.d16;   % left-side estimate
psd.sigma_g2 = psd.d84 / psd.d50;   % right-side estimate

%  Span (normalised width of the distribution):
psd.span = (psd.d90 - psd.d10) / psd.d50;

%% 6) Printed summary
fprintf('============================================\n')
fprintf(' Particle size distribution  --  summary   \n')
fprintf('============================================\n')
fprintf(' d10  = %7.2f  um\n', psd.d10)
fprintf(' d16  = %7.2f  um\n', psd.d16)
fprintf(' d50  = %7.2f  um\n', psd.d50)
fprintf(' d84  = %7.2f  um\n', psd.d84)
fprintf(' d90  = %7.2f  um\n', psd.d90)
fprintf(' ------------------------------------------\n')
fprintf(' sigma_g (left)   = %.4f\n', psd.sigma_g1)
fprintf(' sigma_g (right)  = %.4f\n', psd.sigma_g2)
fprintf(' Span             = %.4f\n', psd.span)
fprintf('============================================\n\n')

%% 7) Visualisation
figure('Name','Particle Size Distribution','Position',[100 100 800 520])

%  Left axis: density distribution q3
yyaxis left
plot(psd.x, psd.q3, 'b')
ylabel('density distribution  q_3  /  \mum^{-1}')
ylim([0, max(psd.q3) * 1.15])

%  Right axis: cumulative distribution Q3
yyaxis right
plot(psd.x_upper, psd.Q3, 'r')
ylabel('cumulative distribution  Q_3  /  -')
ylim([0, 1.15])

%  Mark characteristic diameters as horizontal reference lines
d_vals   = [psd.d10, psd.d16, psd.d50, psd.d84, psd.d90];
Q3_vals  = [0.10,    0.16,    0.50,    0.84,    0.90   ];
d_labels = {'d_{10}','d_{16}','d_{50}','d_{84}','d_{90}'};

for i = 1:numel(d_vals)
    xline(d_vals(i), '--k', d_labels{i}, ...
          'LabelVerticalAlignment','bottom', ...
          'LabelHorizontalAlignment','right', ...
          'FontSize', 9, 'LineWidth', 0.8)
end

xlabel('particle diameter  /  \mum')
title('Volume-weighted particle size distribution')

%% 8) Export as self-documenting JSON
psd.doc = sprintf(['PSD of sample SXX-966. ' ...
    'Source: psd.csv (received from Dr. Evil, 09 Jul 2020). ' ...
    'Processed with working_with_psd.m on %s.'], datestr(now, 'yyyy-mm-dd'));

fid = fopen('PSD.json', 'w');
fwrite(fid, jsonencode(psd, 'PrettyPrint', true));
fclose(fid);

fprintf('JSON written to PSD.json\n')
