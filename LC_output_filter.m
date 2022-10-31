close, clear, clc;
L = 100e-6; % H
Rl = 25e-3; % Ohm
C = 680e-6; % F
Rc = 21e-3; % Ohm

% Ressonance frequency
fr = 1 / (2*pi*sqrt(L*C)); % Hz
wr = 1 / sqrt(L*C); % rad/s
H_LCr_abs_r = 20 * log10( sqrt( (1 + (Rc*C*wr)^2) / ...
    ((L*C*wr^2)^2 + (((Rl+Rc)*C)^2 - 2*L*C)*wr^2 + 1) ) ); % dB

% Cutoff frequency
fc = sqrt((10^0.15 + 1) / (L*C)); % Hz
wc = 2*pi * sqrt((10^0.15 + 1) / (L*C)); % rad/s
H_LCr_abs_c = 20 * log10( sqrt( (1 + (Rc*C*wc)^2) / ...
    ((L*C*wc^2)^2 + (((Rl+Rc)*C)^2 - 2*L*C)*wc^2 + 1) ) ); % dB

% Transfer functions
w = 100 : 0.1 : 1e5; % rad/s
H_LC_abs = 20 * log10(1 ./ abs(1 - L*C*w.^2)); % dB
H_LCr_abs = 20 * log10( sqrt( (1 + (Rc*C*w).^2) ./ ...
    ((L*C*w.^2).^2 + (((Rl+Rc)*C)^2 - 2*L*C)*w.^2 + 1) ) ); % dB
w = log10(w); % rad/s

% Plot
figure(1), set(gcf,'color','w');
plot(w,H_LC_abs,'k', w,H_LCr_abs,'r'), xlabel('log(w) [rad/s]');
ylabel('|H(w)| [dB]'), title('Bode diagram'), grid on;
legend('LC filter','LC filter with parasitic resistances');