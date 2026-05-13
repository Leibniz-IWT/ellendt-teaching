%% ========================================================================
%  INTRODUCTION TO FFT  —  Part 4: Amplitude modulation + additive noise
%  ========================================================================
%
%  The signal now has two types of noise:
%    - Additive white noise  (signal + noise)
%    - Multiplicative noise  (signal × (1 + noise))  — random amplitude
%
%  Amplitude modulation broadens the spectral peaks because the carrier
%  frequency now has sidebands. Compare peak heights and widths to Part 3.
%
%  Topics:
%    1. Multiplicative (amplitude) noise and its spectral signature
%    2. Sideband broadening in the power spectrum
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
f0        = 100;   % base frequency              [Hz]
n_noise   = 10;    % additive noise amplitude
n_amp     = 1;     % multiplicative noise amplitude (100% modulation depth)

%% 3) Generate signal
t      = linspace(0, 0.1, 1000);
signal = sin(2*pi *     f0 * t) ...
       + cos(2*pi * 3.7*f0 * t) ...
       + cos(2*pi * 8.9*f0 * t + pi/3);
signal = signal + (rand(size(t)) - 0.5) * n_noise;        % additive noise
signal = signal .* (1 + (rand(size(t)) - 0.5) * n_amp);   % multiplicative noise

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

fprintf('Additive noise      : %.0fx signal\n',   n_noise)
fprintf('Multiplicative noise: %.0f%% modulation\n', n_amp*100)
fprintf('Detected peaks:\n')
for k = 1:numel(f_peaks)
    fprintf('  f = %7.1f Hz   power = %.4f\n', f_peaks(k), peak_vals(k))
end

%% 6) Plot
figure('Name','FFT Part 4','Position',[100 100 900 420])

subplot(1,2,1)
plot(t, signal)
xlabel('t / s')
ylabel('signal / a.u.')
title('Time domain — additive + multiplicative noise')

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
title('Frequency domain — broadened peaks with sidebands')
xlim([0 f_s/2])
