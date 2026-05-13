%% ========================================================================
%  INTRODUCTION TO FFT  —  Part 1: Single frequency, additive noise
%  ========================================================================
%
%  A single sine wave is buried in additive white noise. The FFT recovers
%  the signal frequency from the power spectrum even when the noise
%  amplitude is much larger than the signal.
%
%  Topics:
%    1. Generating a noisy signal
%    2. Computing the FFT and one-sided power spectrum
%    3. Identifying the dominant frequency with max()
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
f_sig   = 100;    % signal frequency          [Hz]
n_noise = 15;     % noise amplitude (15x signal amplitude)

%% 3) Generate signal
t      = linspace(0, 0.1, 1000);             % time vector  [s]
signal = sin(2*pi * f_sig * t);              % pure sine
signal = signal + (rand(size(t)) - 0.5) * n_noise;  % add white noise

%% 4) FFT and one-sided power spectrum
N     = length(signal);
Y     = fft(signal, N);
P_two = abs(Y / N).^2;                       % two-sided power

f_s   = 1 / (t(2) - t(1));                  % sampling frequency  [Hz]
f_ax  = f_s * (0:(N/2)) / N;                % one-sided frequency axis

P     = P_two(1:N/2+1);                     % one-sided spectrum

%% 5) Identify dominant frequency
[~, idx] = max(P);
f_peak   = f_ax(idx);

fprintf('Sampling frequency : %.0f Hz\n',   f_s)
fprintf('Frequency resolution: %.2f Hz\n',  f_s/N)
fprintf('Detected peak      : %.1f Hz\n',   f_peak)

%% 6) Plot
figure('Name','FFT Part 1','Position',[100 100 900 420])

subplot(1,2,1)
plot(t, signal)
xlabel('t / s')
ylabel('signal / a.u.')
title('Time domain — noisy signal')

subplot(1,2,2)
plot(f_ax, P)
xline(f_peak, 'r--', sprintf('%.0f Hz', f_peak), ...
      'LabelVerticalAlignment','bottom')
xlabel('f / Hz')
ylabel('power / a.u.')
title('Frequency domain — power spectrum')
xlim([0 f_s/2])
