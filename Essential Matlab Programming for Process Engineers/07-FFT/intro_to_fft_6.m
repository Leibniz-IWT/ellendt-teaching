%% ========================================================================
%  INTRODUCTION TO FFT  —  Part 6: Frequency noise (three frequencies)
%  ========================================================================
%
%  The three-frequency signal from Part 2 is given correlated frequency
%  noise: all three carriers share the same instantaneous frequency
%  deviation f_noisy(t), as if the signal source had a drifting clock.
%
%  Compare with Part 5 (single broadened peak) and Parts 2–3 (sharp peaks
%  from amplitude noise) to see the difference between the two noise types.
%
%  Topics:
%    1. Correlated frequency noise across multiple carriers
%    2. Spectral broadening scales with frequency (higher f → wider peak)
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
f0      = 100;     % base frequency      [Hz]
n_noise = 0.05;    % frequency noise (5% of f0)

%% 3) Generate signal — shared frequency deviation for all carriers
t      = linspace(0, 0.1, 1000);
f_inst = f0 * (1 + (rand(size(t)) - 0.5) * n_noise);  % noisy base frequency

signal = sin(2*pi *      f_inst .* t) ...
       + cos(2*pi *  3.7*f_inst .* t) ...
       + cos(2*pi *  8.9*f0     *  t + pi/3);  % third component: fixed frequency

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

fprintf('Frequency noise     : ±%.0f%%\n', n_noise*50)
fprintf('Detected peaks:\n')
for k = 1:numel(f_peaks)
    fprintf('  f = %7.1f Hz   power = %.4f\n', f_peaks(k), peak_vals(k))
end

%% 6) Plot
figure('Name','FFT Part 6','Position',[100 100 900 420])

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
    for k = 1:numel(f_peaks)
        text(f_peaks(k), peak_vals(k)*1.05, sprintf('%.0f Hz', f_peaks(k)), ...
             'HorizontalAlignment','center', 'FontSize', 9, 'Color','r')
    end
end
xlabel('f / Hz')
ylabel('power / a.u.')
title('Frequency domain — broadened peaks (third peak is sharp)')
xlim([0 f_s/2])
