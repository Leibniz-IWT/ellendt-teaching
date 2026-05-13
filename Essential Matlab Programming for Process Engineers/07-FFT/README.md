# Introduction to the Fast Fourier Transform (FFT)

---

## Topic

This lecture series introduces the Discrete Fourier Transform and its fast implementation (FFT) through a single evolving example: a signal built from three sinusoids is progressively degraded with different types of noise. Each part adds one new complication, making the spectral analysis progressively harder — and revealing a different property of the Fourier transform.

The series closes with a simple but powerful application: frequency-domain filtering, where noise is removed by zeroing spectral bins and transforming back to the time domain.

---

## Files

| File | Signal | Noise type | New concept |
|---|---|---|---|
| `intro_to_fft.m` | 1 frequency | Additive, large | FFT basics, one-sided spectrum, `max` |
| `intro_to_fft_2.m` | 3 frequencies | None | Multiple peaks, `findpeaks` |
| `intro_to_fft_3.m` | 3 frequencies | Additive, heavy | Noise floor, FFT robustness |
| `intro_to_fft_4.m` | 3 frequencies | Additive + multiplicative | Amplitude modulation, sideband broadening |
| `intro_to_fft_4_filter.m` | 3 frequencies | Additive + multiplicative | Spectral filter, `ifft`, conjugate symmetry |
| `intro_to_fft_5.m` | 1 frequency | Frequency noise | Peak broadening vs noise floor |
| `intro_to_fft_6.m` | 3 frequencies | Frequency noise | Broadening scales with frequency |

---

## Background: The Fourier Transform

Any periodic signal can be represented as a sum of sinusoids. The Fourier transform decomposes a signal into its frequency components — it answers the question: *which frequencies are present, and at what amplitude?*

For a continuous signal $x(t)$ the Fourier transform is:

$$X(f) = \int_{-\infty}^{\infty} x(t)\, e^{-j 2\pi f t}\, dt$$

---

## Equations

### 1 — Discrete Fourier Transform (DFT)

For $N$ uniformly sampled values $x_n = x(n \Delta t)$, the DFT is:

$$X_k = \sum_{n=0}^{N-1} x_n\, e^{-j 2\pi k n / N}, \qquad k = 0, 1, \ldots, N-1$$

The FFT is an algorithm that computes the same result in $\mathcal{O}(N \log N)$ operations instead of $\mathcal{O}(N^2)$. In MATLAB: `Y = fft(signal, N)`.

### 2 — Frequency axis

With $N$ samples at sampling interval $\Delta t$, the sampling frequency is $f_s = 1/\Delta t$. The DFT output $X_k$ corresponds to frequency:

$$f_k = k \cdot \frac{f_s}{N}, \qquad k = 0, 1, \ldots, N-1$$

The highest representable frequency (Nyquist limit) is $f_s/2$. Frequencies above this are aliased back into the spectrum.

In MATLAB:
```matlab
f_s  = 1 / (t(2) - t(1));
f_ax = f_s * (0:(N/2)) / N;        % one-sided frequency axis
```

### 3 — Nyquist–Shannon sampling theorem

A signal containing frequencies up to $f_\text{max}$ must be sampled at:

$$f_s > 2\, f_\text{max}$$

Below this rate, high-frequency components fold back as aliases at lower frequencies and cannot be distinguished from real low-frequency content.

### 4 — Frequency resolution

The DFT has a finite frequency resolution determined by the total record length $T = N \Delta t$:

$$\Delta f = \frac{f_s}{N} = \frac{1}{T}$$

Two frequencies closer than $\Delta f$ cannot be resolved. Longer records → finer resolution.

### 5 — One-sided power spectrum

Because the input signal is real-valued, the DFT is conjugate symmetric: $X_k = X^*_{N-k}$. The useful information is in the first half only. The one-sided power spectrum is:

$$P_k = \left|\frac{X_k}{N}\right|^2, \qquad k = 0, 1, \ldots, \frac{N}{2}$$

In MATLAB:
```matlab
P = abs(Y / N).^2;
P = P(1:N/2+1);                     % keep positive frequencies only
```

### 6 — Additive white noise and the noise floor

White noise has equal power at all frequencies. With $N$ bins, the total noise power is spread uniformly, so the noise floor in the one-sided power spectrum is:

$$P_\text{noise} \approx \frac{\sigma^2}{N}$$

where $\sigma^2$ is the noise variance. Signal peaks rise above this floor in proportion to $N$ — longer records improve SNR. This is why the FFT can detect a signal even when the time-domain SNR is well below 1.

### 7 — Multiplicative (amplitude) noise

When the signal is multiplied by a random amplitude envelope $a(t)$:

$$x(t) = a(t) \cdot s(t), \qquad a(t) = 1 + \epsilon(t)$$

the spectrum of $x$ is the convolution of the spectra of $a$ and $s$. Each spectral peak of $s$ acquires sidebands at the frequencies of the amplitude modulation — the peak broadens rather than a flat floor rising.

### 8 — Frequency noise

When the instantaneous frequency is randomly perturbed:

$$x(t) = \sin\!\bigl(2\pi\, f(t)\cdot t\bigr), \qquad f(t) = f_0\bigl(1 + \epsilon(t)\bigr)$$

the signal energy spreads into neighbouring frequency bins. The width of the broadened peak scales with $f_0$: a higher carrier frequency shows more broadening for the same fractional noise level.

### 9 — Spectral filtering and the inverse FFT

The inverse DFT recovers the time-domain signal from its spectrum:

$$x_n = \frac{1}{N} \sum_{k=0}^{N-1} X_k\, e^{+j 2\pi k n / N}$$

In MATLAB: `x = ifft(Y)`. For the output to be real, the spectrum must have **conjugate symmetry**: $X_k = X^*_{N-k}$. The simplest filter:

1. `Y = fft(signal)` — transform to frequency domain
2. Zero all bins except the dominant peaks
3. `signal_clean = real(ifft(Y_filtered))` — transform back

When keeping bin $k$ (positive frequency), the mirror bin at $N - k + 2$ must also be kept to preserve conjugate symmetry and produce a real output.

---

## MATLAB Concepts Introduced

| Concept | Where used |
|---|---|
| `fft(x, N)` — FFT of a real signal | All parts |
| One-sided power spectrum `abs(Y/N).^2` | All parts |
| Frequency axis construction | All parts |
| `max` for single peak detection | Part 1 |
| `findpeaks` with `'Threshold'` for multiple peaks | Parts 2–6 |
| `ifft` and conjugate symmetry | Part 4b |
| Multiplicative noise `.* (1 + noise)` | Parts 4, 4b |
| Random instantaneous frequency `f0*(1+noise)` | Parts 5, 6 |
| `xline` for annotating frequency locations | Parts 1, 4b, 5 |

---

## Learning Goals

After completing this lecture series, students should be able to:

1. **Explain the DFT** as a decomposition of a discrete signal into sinusoidal basis functions and identify the output as complex amplitudes at discrete frequencies.
2. **Construct the frequency axis** from the sampling frequency and record length, and calculate the frequency resolution $\Delta f = f_s/N$.
3. **Apply the Nyquist criterion** and explain what aliasing looks like in a spectrum.
4. **Interpret the one-sided power spectrum** and explain why only the first half of the FFT output contains independent information for real signals.
5. **Explain why additive white noise raises the floor uniformly** while frequency noise broadens peaks, and distinguish the two cases visually in a spectrum.
6. **Use `findpeaks`** to detect multiple spectral peaks and select an appropriate threshold.
7. **Implement a simple spectral filter**: FFT → zero non-peak bins (both positive and conjugate mirror) → `ifft` → `real`.

---

## Further Reading

- Oppenheim, A.V.; Schafer, R.W.: *Discrete-Time Signal Processing*, Chapter 8 (The DFT)
- Cooley, J.W.; Tukey, J.W.: *An Algorithm for the Machine Calculation of Complex Fourier Series*, Math. Comput. 19 (1965) 297–301 (original FFT paper)
- MathWorks Documentation: `fft` — https://de.mathworks.com/help/matlab/ref/fft.html
