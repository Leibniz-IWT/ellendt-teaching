%% ========================================================================
%  INTRODUCTION TO FFT  —  Part 4b: Spectral filtering
%  ========================================================================
%
%  The simplest possible filter in the frequency domain:
%    1. FFT the noisy signal
%    2. Zero out all bins except the dominant peaks
%    3. Inverse FFT to reconstruct the clean signal
%
%  This works because the signal energy is concentrated at a few discrete
%  frequencies while noise is spread uniformly across all bins.
%
%  NOTE: When zeroing the one-sided spectrum, both the positive-frequency
%  bin and its conjugate mirror in the negative-frequency half must be
%  kept to produce a real-valued output from ifft.
%
%  Topics:
%    1. Spectral (frequency-domain) filtering
%    2. ifft and the requirement for conjugate symmetry
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
f0      = 100;    % base frequency               [Hz]
n_noise = 15;     % additive noise amplitude
n_amp   = 0.5;    % multiplicative noise amplitude (50% modulation depth)

%% 3) Generate signal
t      = linspace(0, 0.1, 1000);
signal = sin(2*pi *     f0 * t) ...
       + cos(2*pi * 3.7*f0 * t) ...
       + cos(2*pi * 8.9*f0 * t + pi/3);
signal = signal + (rand(size(t)) - 0.5) * n_noise;
signal = signal .* (1 + (rand(size(t)) - 0.5) * n_amp);

%% 4) FFT and one-sided power spectrum
N     = length(signal);
Y     = fft(signal, N);
P_two = abs(Y / N).^2;

f_s  = 1 / (t(2) - t(1));
f_ax = f_s * (0:(N/2)) / N;
P    = P_two(1:N/2+1);

%% 5) Find peaks in one-sided spectrum
[~, peak_idx] = findpeaks(P, 'Threshold', 0.1);
f_peaks = f_ax(peak_idx);

fprintf('Detected peaks (before filtering):\n')
for k = 1:numel(f_peaks)
    fprintf('  f = %7.1f Hz\n', f_peaks(k))
end

%% 6) Spectral filter — keep only peak bins, zero everything else
%
%  The full FFT of a real signal has conjugate symmetry:
%      Y(k)  and  Y(N-k+2)  are complex conjugates  (k = 2 … N/2)
%  Both halves must be retained so that ifft produces a real output.

Y_filt = zeros(size(Y));

for k = peak_idx(:)'
    Y_filt(k) = Y(k);                  % positive-frequency bin
    mirror = N - k + 2;                % index of the conjugate mirror
    if mirror >= 1 && mirror <= N
        Y_filt(mirror) = Y(mirror);    % conjugate mirror bin
    end
end

filtered = real(ifft(Y_filt));         % imaginary residual is numerical noise

%% 7) Plot
figure('Name','FFT Part 4b — original vs filtered','Position',[100 100 700 560])

subplot(2,1,1)
plot(t, signal)
xlabel('t / s')
ylabel('signal / a.u.')
title('Original noisy signal')

subplot(2,1,2)
plot(t, filtered)
xlabel('t / s')
ylabel('signal / a.u.')
title(sprintf('Filtered signal — %d frequency bins retained', numel(peak_idx)))

figure('Name','FFT Part 4b — power spectrum','Position',[100 100 700 380])
plot(f_ax, P)
hold on
plot(f_peaks, P(peak_idx), 'rv', 'MarkerFaceColor','r', 'MarkerSize', 8)
xline(f_peaks, '--k', 'LineWidth', 0.8, 'Alpha', 0.4)
xlabel('f / Hz')
ylabel('power / a.u.')
title('Power spectrum with retained bins marked')
xlim([0 f_s/2])
