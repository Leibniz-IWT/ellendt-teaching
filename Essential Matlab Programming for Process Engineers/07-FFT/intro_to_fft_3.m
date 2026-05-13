%% ========================================================================
%  INTRODUCTION TO FFT  —  Part 3: Three frequencies, heavy noise
%  ========================================================================
%
%  Same three-frequency signal as Part 2, but now buried under heavy
%  additive white noise (amplitude 50x the signal). The FFT still
%  resolves the three peaks because signal energy is concentrated at
%  three discrete frequencies while noise is spread uniformly.
%
%  Topics:
%    1. SNR and why FFT is robust against additive white noise
%    2. Noise floor in the power spectrum
%    3. Threshold selection for findpeaks()
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
f0      = 100;    % base frequency             [Hz]
n_noise = 50;     % noise amplitude (50x signal amplitude)

%% 3) Generate signal
t      = linspace(0, 0.1, 1000);
signal = sin(2*pi *     f0 * t) ...
       + cos(2*pi * 3.7*f0 * t) ...
       + cos(2*pi * 8.9*f0 * t + pi/3);
signal = signal + (rand(size(t)) - 0.5) * n_noise;

%% 4) FFT and one-sided power spectrum
N     = length(signal);
Y     = fft(signal, N);
P_two = abs(Y / N).^2;

f_s  = 1 / (t(2) - t(1));
f_ax = f_s * (0:(N/2)) / N;
P    = P_two(1:N/2+1);

%% 5) Peak detection
[peak_vals, peak_idx] = findpeaks(P, 'Threshold', 0.1);
f_peaks = f_ax(peak_idx);

fprintf('Noise amplitude     : %.0fx signal\n', n_noise)
fprintf('Detected peaks:\n')
for k = 1:numel(f_peaks)
    fprintf('  f = %7.1f Hz   power = %.4f\n', f_peaks(k), peak_vals(k))
end

%% 6) Plot
figure('Name','FFT Part 3','Position',[100 100 900 420])

subplot(1,2,1)
plot(t, signal)
xlabel('t / s')
ylabel('signal / a.u.')
title(sprintf('Time domain — noise amplitude = %dx signal', n_noise))

subplot(1,2,2)
plot(f_ax, P)
hold on
plot(f_peaks, peak_vals, 'rv', 'MarkerFaceColor','r', 'MarkerSize', 8)
for k = 1:numel(f_peaks)
    text(f_peaks(k), peak_vals(k)*1.05, sprintf('%.0f Hz', f_peaks(k)), ...
         'HorizontalAlignment','center', 'FontSize', 9, 'Color','r')
end
xlabel('f / Hz')
ylabel('power / a.u.')
title('Frequency domain — peaks survive heavy noise')
xlim([0 f_s/2])
