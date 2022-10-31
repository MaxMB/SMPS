close, clear, clc; format long;
%%% System parameters
Lf = 98e-6; % [H]   Inductor
RLf = 26e-3; % [Ohm] Inductor resistance
Cf = 685e-6; % [F]   Capacitor
RCf = 20e-3; % [Ohm] Capacitor resistance
Rl = 10;     % [Ohm] Load resistance
Vi = 179.6;    % [V]   Mean input voltage: 141.4 | 179.6 | 200
N = 1.5;     %       Transformer turns ratio
Ts = 1e-5;   % [s]   Sample period
Dmax = 0.45; %       Max duty cicle

%%% Linear continuous-time model
A = [ -1/(Cf*(Rl+RCf)),          Rl/(Cf*(Rl+RCf));
     -Rl/(Lf*(Rl+RCf)), -(RLf+Rl*RCf/(Rl+RCf))/Lf];
B = [0;  Vi/(N*Lf)];
C = [Rl/(Rl+RCf),  Rl*RCf/(Rl+RCf)];
D = 0;

%%% Microcontroller
Ad = [0.997804369618173, 0.014625348088769;
     -0.099452367003629, 0.994686874295616];
Bd = [0.087557083891431; 11.941525420783089];
Cd = [0.995766824623838, 0.028197671115147];
K = [0.033293762099687, 0.032463881530606, ...
    0.000230526126952];
Le = [0.349035208102762; 8.644382966325479];

% Simulation
var_v = (0.01)^2; % measurement noise variance
var_xd = var_v; % process noise variance
qtz_in = 5 / 2^10; % measurement quantization interval
qtz_ctr = 1 / 2^5; % control quantization interval
Sat_max = 5; % saturation max value
Sat_min = 0; % saturation min value
G = 1 / (30 / Sat_max); % Resistive voltage divider gain
tf = 0.06; % [s] final time
t_step = Ts / 10; % [s] simulation step
sim('Control_Simulink.slx');

% Plot
figure(1), set(gcf,'color','w');
subplot(211), stairs(0:Ts:tf,d,'k'), grid on;
    title(['Forward Converter - Soft Mismatch - Vi=' ...
        num2str(Vi) 'V | Rload=' num2str(Rl) 'Ohm']);
    xlabel('Time (s)'), ylabel('Duty Cicle'), xlim([0,tf]);
subplot(212), plot(t,r,'r',t,vo,'k'), grid on, xlim([0,tf]);
    xlabel('Time (s)'), ylabel('Voltage [V]');
    legend('Reference','Load');