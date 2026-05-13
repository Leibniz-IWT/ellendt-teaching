%% ========================================================================
%  INTRODUCTION TO FFT  —  Part 5: Frequency noise (single frequency)
%  ========================================================================
%
%  Instead of adding noise to the amplitude, noise is added to the
%  instantaneous frequency: f(t) = f0 * (1 + noise(t)).
%  This produces a signal with a randomly varying pitch.
%
%  In the power spectrum, frequency noise appears as peak broadening
%  rather than a raised noise floor — the energy is smeared across
%  neighbouring bins rather than distributed uniformly.
%
%  Topics:
%    1. Frequency noise vs amplitude noise — different spectral signatures
%    2. Peak broadening and frequency resolution limits
%  ========================================================================

clear; close all; clc

%% 1) Plot defaults
set(0, 'DefaultLineLineWidth',  1.5, ...
       'DefaultAxesFontSize',   11,  ...
       'DefaultAxesLineWidth',  1.0, ...
       'DefaultAxesBox',        'on', ...
       'DefaultAxesXGrid',      'on', ...
       'DefaultAxesYGrid',      'on', ...
       'DefaultFigureColor',    'w');

%% 2) Signal parameters
f0      = 100;     % nominal frequency   [Hz]
n_noise = 0.15;    % frequency noise (15% of f0)

%% 3) Generate signal with noisy instantaneous frequency
t       = linspace(0, 0.1, 1000);
f_inst  = f0 * (1 + (rand(size(t)) - 0.5) * n_noise);   % noisy frequency
signal  = sin(2*pi * f_inst .* t);

%% 4) FFT and one-sided power spectrum
N     = length(signal);
Y     = fft(signal, N);
P_two = abs(Y / N).^2;

f_s  = 1 / (t(2) - t(1));
f_ax = f_s * (0:(N/2)) / N;
P    = P_two(1:N/2+1);

%% 5) Peak detection
[peak_vals, peak_idx] = findpeaks(P, 'Threshold', 0.02);
f_peaks = f_ax(peak_idx);

fprintf('Nominal frequency   : %.0f Hz\n',          f0)
fprintf('Frequency noise     : ±%.0f%%\n',           n_noise*50)
fprintf('Frequency resolution: %.2f Hz\n',           f_s/N)
fprintf('Detected peaks:\n')
for k = 1:numel(f_peaks)
    fprintf('  f = %7.1f Hz   power = %.4f\n', f_peaks(k), peak_vals(k))
end

%% 6) Plot
figure('Name','FFT Part 5','Position',[100 100 900 420])

subplot(1,2,1)
plot(t, signal)
xlabel('t / s')
ylabel('signal / a.u.')
title(sprintf('Time domain — frequency noise ±%.0f%%', n_noise*50))

subplot(1,2,2)
plot(f_ax, P)
hold on
if ~isempty(f_peaks)
    plot(f_peaks, peak_vals, 'rv', 'MarkerFaceColor','r', 'MarkerSize', 8)
end
xline(f0, 'b--', sprintf('f_0 = %.0f Hz', f0), 'LabelVerticalAlignment','bottom')
xlabel('f / Hz')
ylabel('power / a.u.')
title('Frequency domain — broadened peak')
xlim([0, 3*f0])
