% Signal Analysis and Filtering Demo
% Demonstrates spectral analysis and digital filtering

% Parameters
fs = 1000;              % Sampling frequency (Hz)
T = 1/fs;               % Sampling period
duration = 1;           % Signal duration (seconds)
L = fs * duration;      % Signal length
t = (0:L-1)*T;         % Time vector

% Generate a test signal with multiple frequencies and noise
f1 = 50;   % Main signal frequency (Hz)
f2 = 120;  % Second component
f3 = 200;  % Third component
noise_amp = 0.3;

% Create clean and noisy signals
clean_signal = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t) + 0.25*sin(2*pi*f3*t);
noisy_signal = clean_signal + noise_amp*randn(size(t));

% Compute FFT of noisy signal
Y = fft(noisy_signal);
P2 = abs(Y/L);          % Two-sided spectrum
P1 = P2(1:L/2+1);       % Single-sided spectrum
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;     % Frequency vector

% Design a lowpass filter to remove high-frequency noise
cutoff = 250;  % Cutoff frequency (Hz)
order = 6;     % Filter order
[b, a] = butter(order, cutoff/(fs/2), 'low');

% Apply the filter
filtered_signal = filtfilt(b, a, noisy_signal);  % Zero-phase filtering

% Plot results
figure('Position', [100 100 800 1000]);

% Time domain plots
subplot(3,1,1);
plot(t, clean_signal, 'b', 'LineWidth', 1.5);
hold on;
plot(t, noisy_signal, 'r', 'LineWidth', 0.5);
title('Original Signals');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Clean', 'Noisy');
grid on;

% Frequency domain plot
subplot(3,1,2);
plot(f, P1, 'b');
title('Single-Sided Amplitude Spectrum');
xlabel('Frequency (Hz)');
ylabel('|P1(f)|');
xlim([0 300]);  % Limit x-axis to relevant frequencies
grid on;

% Filtered signal plot
subplot(3,1,3);
plot(t, clean_signal, 'b', 'LineWidth', 1.5);
hold on;
plot(t, filtered_signal, 'r', 'LineWidth', 1);
title('Clean vs Filtered Signal');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Original Clean', 'Filtered');
grid on;

% Display the filter's frequency response
figure('Position', [900 100 600 400]);
[h, w] = freqz(b, a, 1024, fs);
plot(w, 20*log10(abs(h)));
title('Filter Frequency Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;