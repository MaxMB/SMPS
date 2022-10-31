close, clear, clc; format long;
%%% System parameters
Lf = 100e-6; % [H]   Inductor
RLf = 25e-3; % [Ohm] Inductor resistance
Cf = 680e-6; % [F]   Capacitor
RCf = 21e-3; % [Ohm] Capacitor resistance
Rl = 10;     % [Ohm] Load resistance
Vi = 179.6;  % [V]   Mean input voltage
N = 1.5;     %       Transformer turns ratio
Dmax = 0.45; %       Max duty cicle

%%% Linear continuous-time model: x' = [vC, iL]
% dx(t) = A*x(t) + B*u(t)
%  y(t) = C*x(t) + D*u(t)
A = [ -1/(Cf*(Rl+RCf)),          Rl/(Cf*(Rl+RCf));
     -Rl/(Lf*(Rl+RCf)), -(RLf+Rl*RCf/(Rl+RCf))/Lf];
B = [0;  Vi/(N*Lf)];
C = [Rl/(Rl+RCf),  Rl*RCf/(Rl+RCf)];
D = 0;
sys = ss(A, B, C, D);

%%% Linear discrete-time model
% x[k+1] = Ad*x[k] + Bd*u[k]
%   y[k] =  C*x[k] +  D*u[k]
Ts = 1e-5; % sample period [s]
%sysd = c2d(sys, Ts, 'zoh');
sysd = c2d(sys, Ts, 'Tustin');
Ad = sysd.a;
Bd = sysd.b;
Cd = sysd.c;

%%% Integral action augmented model: x_aug' = [vC, iL, w]
% Error integral:
% w[k+1] = w[k] + e[k] = w[k] + y[k] - r[k]
% w[k+1] = w[k] + C*x[k] - r[k]
% State augmentation:
% |x[k+1]| = |Ad 0|*|x[k]| + |Bd|*u[k] - |0|*r[k]
% |w[k+1]|   | C I| |w[k]|   | 0|        |I|
Ad_aug = [Ad, [0;0]; Cd, 1];
Bd_aug = [Bd; 0];
% Controlability -> rank(ctrb(Ad_aug,Bd_aug))
% Ouput augmentation: |y[k]| = |C 0| * |x[k] w[k]|'
% Observability -> rank(ctrb(Ad',Cd'))

%%% Optimal control - LQR
% Bryson rule
Q1 = diag([30^(-2), 11.33^(-2), 0]);
Q2 = 0.45^(-2);
% Pincer procedure
ts = 0.01; % settling time
alpha = 100^(Ts/ts);
K = dlqr(alpha*Ad_aug, alpha*Bd_aug, Q1, Q2);

%{
%%% Full Prediction Estimator
zp = eig(Ad_aug - Bd_aug * K);
sp = log(zp) / Ts;
sp_obs = - 2 * max(abs(sp)) * (cos(pi/3) + 1i*sin(pi/3));
Ps_obs = [sp_obs; sp_obs'];
Pz_obs = exp(Ts * Ps_obs);
Le = place(Ad', Cd', Pz_obs)';
%}

%%% Kalman Filter - LQG
var_v = (0.01)^2; % measurement noise variance
var_xd = var_v; % process noise variance
% Spectal power of white noise = var_n * I
Rd = var_xd; % covariance matrix of process noise
Rv = var_v; % covariance matrix of measurement noise
[~, Le, ~] = kalman(sysd, Rd, Rv, 0);

%%% Simulation
qtz_in = 5 / 2^10; % measurement quantization interval
qtz_ctr = 1 / 2^10; % control quantization interval
Sat_max = 5; % saturation max value
Sat_min = 0; % saturation min value
G = 1 / (30 / Sat_max); % Resistive voltage divider gain
tf = 0.06; % [s] final time
t_step = Ts / 10; % [s] simulation step
sim('Control_Simulink.slx');

%%% Plot
figure(1), set(gcf,'color','w');
subplot(211), stairs(0:Ts:tf,d,'k'), grid on;
    title('Forward Converter - Control Effort');
    xlabel('Time (s)'), ylabel('Duty Cicle'), xlim([0,tf]);
subplot(212), plot(t,r,'r',t,vo,'k'), grid on, xlim([0,tf]);
    title('Forward Converter - Output');
    xlabel('Time (s)'), ylabel('Voltage [V]');
    legend('Reference','Load');