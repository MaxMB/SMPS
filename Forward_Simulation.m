close, clear, clc;
% Inductor (Forward Converter)
L = 100e-6; % [H]
RL = 25e-3; % [Ohm]

% Capacitor (Forward Converter)
C = 470e-6; % [F]
RC = 0.02;  % [Ohm]

% Transformer (Forward Converter)
Lm = 180e-6;      % [H]
Rm = 100;         % [Ohm]
L_leak = 0.45e-6; % [H]
RT1 = 0.025;      % [Ohm]
RT2 = 0.01;       % [Ohm]
VT1rms = 201;     % turns ratio N = 1.5
VT2rms = VT1rms / 1.5;     % turns ratio N = 1.5
PT = 90;

% Transistor Q1 & Q2 (PWM swuitches)
RDS = 0.55; % [Ohm]
VGSth = 4;  % [V]

% Diodes D1-D4 & DB1-DB4
Vf = 0.8;  % [V]
Rf = 0.06; % [Ohm]

% Capacitor (DC link)
C_bulk = 1e-3;  % [F]
RC_bulk = 0.03; % [Ohm]

% Resistance (load)
R_load = 1e3; % [Ohm]

% Line Voltage
Vp = sqrt(2) * 127; % [V]
F_line = 60;        % [Hz]

% Microcontroller
Amp = 1;       % [V]  PWM amplification
F_PWM = 1e5;   % [Hz] PWM frequency
T_ctrl = 1e-4; % [s]  Controller period
Vref = 2;      % [V]  Virtual voltage reference
Dmax = 0.45;   %      Max duty cicle
t_init = 0.1;  % [s]  Initialization time
r = 2;         % [V]  Voltage virtual reference
K = [0.0045, 0.0045, 0.00012]; % controller gains
%{
% Simulation
tf = 2;     % [s] final time
t_step = 1e-6; % [s] simulations step
sim('Forward_Simulink.slx');

% Plot
figure(1);
subplot(411), stairs(t,vi,'k'), grid on, xlabel('Time (s)'), ylabel('V_{I} [V]');
subplot(412), plot([0,td(end)],[r,r],'r'), hold on, stairs(td,vo,'k'), hold off, grid on;
    xlabel('Time (s)'), ylabel('V_{O} [V]');
subplot(413), stairs(td,d,'k'), grid on, xlabel('Time (s)'), ylabel('Duty Cycle');
subplot(414), stairs(td,il,'k'), grid on, xlabel('Time (s)'), ylabel('I_{L} [A]');
%}