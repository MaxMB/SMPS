close, clear, clc; format long;
% Initial data
f = 60; % mains frequency [Hz]
T = 1 / f; % mains period [s]
w = 2 * pi * f; % angular velocity [rad/s]
p = 0.85; % admissible input voltage drop
Po = 300; % max output power [W]
Vp = sqrt(2) * 100; % input peak voltage [V]
eff_DC_DC = 0.868576; % DC-DC convertor efficiency
Dmax = 0.366357; % max duty cicle

% Minimal bulk capacitance [F]
tmin = acos(-p) / w % [s]
C_Bulk_min = 2 * Po * tmin / (eff_DC_DC * Vp^2 * (1 - p^2))

% Selected bulk capacitance [F]
C_Bulk = 1200e-6;

% New values
fun = @(p) C_Bulk * w * eff_DC_DC * Vp^2 * (1 - p^2) ...
    - 2 * Po * acos(-p);
p = fsolve(fun,p) % input voltage drop
tmin = acos(-p) / w % [s]

% RMS charge current [A]
I_charge_RMS = C_Bulk * Vp * w * ...
    sqrt(0.5 - p * sqrt(1-p^2) / (2 * w * (T/2 - tmin)))
% RMS discharge current [A]
I_discharge_RMS = 4.12;
% RMS bulk current [A]
I_Bulk_RMS = sqrt((tmin * I_discharge_RMS^2 + ...
    (T/2 - tmin) * I_charge_RMS^2) / (T/2))
% Max bulk current [A]
I_Bulk_max = C_Bulk * Vp * w * sqrt(1 - p^2)

% Bulk capacitor resistence [Ohm]
ESR = 60e-3; % 100Hz and 60 Celcius
% Bulk power dissipation [W]
PC_Bulk = ESR * I_Bulk_RMS^2

% Diode Bridge max current [A]
I_T1_max = 7.795981; % [A]
I_DB_max = I_Bulk_max + 7.78
% Diode Bridge RMS current [A]
I_DB_RMS = sqrt((I_discharge_RMS^2 + I_T1_max * ...
    I_Bulk_max * Dmax + I_charge_RMS^2) * (1 - 2*tmin/T))
% Diode Bridge power dissipation [W]
R_DB_f = 10e-3; % [Ohm]
V_DB_f = 1.1; % [V]
P_DB = (R_DB_f * I_DB_RMS + V_DB_f) * I_DB_RMS

% Efficiency
P_loss_DC_DC = Po * (1 - eff_DC_DC); % [W]
P_loss = P_loss_DC_DC + P_DB + PC_Bulk; % [W]
eff = 1 - P_loss / Po

%{
t = linspace(tmin, T/2, 100);
I_Bulk = C_Bulk * Vp * w * sin(w * t);
figure(1), plot(t,I_Bulk,'k'), grid on;
%}