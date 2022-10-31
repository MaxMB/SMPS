close, clear, clc; format long;
%%% Initial parameters
Vi_RMS_min = 100; % V
Vi_RMS_max = 140; % V
eta = 0.8; % initial efficiency
Vo_max = 30; % V
Io_max = 10; % A
Ts = 1e-5; % s
n = 1.5; % transformer relation

%%% Max output power
Po_max = Vo_max * Io_max; % W

%%% Electrical components properties
L = 100e-6; % H
RL = 25e-3; % Ohm
C = 680e-6; % F
RC = 21e-3; % Ohm
Rds = 0.55; % Ohm
Crss = 120e-12; % F
Vf = 0.82; % V
Rf = 68.3e-3; % Ohm

%%% Peak input voltage
Vip_min = sqrt(2) * Vi_RMS_min; % V
Vip_max = sqrt(2) * Vi_RMS_max; % V

%%% DC-DC CONVERTER DESIGN
re = 0.01; % relative error percent
ite_max = 50; % maximum iteration
for core = 1:9 % EE: 12, 16, 19, 22, 30, 40, 50, 60, 70
    rel_er = 1;
    ite = 0;
    while ((rel_er>re) && (ite<ite_max))
        eta_b = eta;
        
        %%% Duty cycle (max output voltage)
        Dmin = n * Vo_max / (eta * Vip_max);
        Dmax = n * Vo_max / (eta * Vip_min);

        %%% Output inductor
        dIL_max = Ts * Vo_max * (1/eta - Dmin) / L;
        IL_min = Io_max - dIL_max/2;
        IL_max = Io_max + dIL_max/2;

        %%% Transformer design
        [PT, IT1_max, IT1_med, IT1_RMS, Lm, ILm, N1, ...
            N2, Kgfe, Aw1, Aw2, Bop, Ku, wire1, wire2, ...
            RT1, RT2] ...
        = transformer_design (core, n, eta, Ts, Vo_max, ...
            Po_max, IL_max, IL_min, Dmax);

        %%% Power dissipation
        % Transistors Q1 and Q2
        IQ_RMS = sqrt(Dmax*(IT1_max^2 + ...
            IT1_max*IT1_med + IT1_med^2)/3);
        PQ = 2 * (Rds * IQ_RMS^2 + Crss * Vip_max^2 / (2*Ts));
        % Diodes D1 and D2
        ID12_RMS = sqrt(Dmax*ILm^2/3);
        PD12 = 2 * (Vf * Dmax + Rf * ID12_RMS) * ID12_RMS;
        % Diodes D3 and D4
        IL_RMS = sqrt((IL_max^2 + IL_max*IL_min + IL_min^2)/3);
        PD34 = (Vf + Rf * IL_RMS) * IL_RMS;
        % Transformer: PT
        % Capacitor
        PC = RC * dIL_max^2 / 12;
        % Inductor
        PL = RL * IL_RMS^2;
        % Total loss
        P_loss = PQ + PD12 + PD34 + PT + PC + PL;
        % Effeciency
        eta = 1 - P_loss / Po_max;
        
        ite = ite + 1;
        rel_er = abs(1-eta/eta_b) * 100;
    end

    %%% Output inductor
    dIL_max = Ts * Vo_max * (1/eta - Dmin) / L;
    IL_max = Io_max + dIL_max/2;

    %%% Max output voltage ripple
    dVo_max = dIL_max * (Ts/(8*C) + RC) / Vo_max;
    
    %%% Excel write
    xcl_v = [1e3*Kgfe, 100*eta, 1e3*Bop, dIL_max, IL_max, ...
        IL_RMS, IT1_max, IT1_RMS, 100*dVo_max, N1, N2, ...
        1e6*Lm, 1e3*RT1, 1e3*RT2, wire1, wire2, 100*Ku, ...
        100*Dmax];
    xlswrite('Transformer.xlsx',xcl_v,'Range', ...
        ['C' num2str(core+1) ':T' num2str(core+1)]);
end

core_v = [12; 16; 19; 22; 30; 40; 50; 60; 70];
xlswrite('Transformer.xlsx',core_v,'Range','A2:A10');

Kgfe_v = [0.458; 0.842; 1.3; 1.8; 6.7; 11.8; 28.4; ...
    36.4; 75.9]; % 1e-3 cm^beta
xlswrite('Transformer.xlsx',Kgfe_v,'Range','B2:B10');

table_title = {'Core EE', 'Kgfe Geometric (1e-3 cm^beta)', ...
    'Kgfe Simulation (1e-3 cm^beta)', 'Efficiency (%)', ...
    'Bop (mT)', 'dIL max (A)', 'IL max (A)', 'IL RMS (A)', ...
    'IT1 max (A)', 'IT1 RMS (A)', 'dVo max (%)', 'N1', ...
    'N2', 'Lm (mu H)', 'RT1 (mOhm)', 'RT2 (mOhm)', ...
    'Wire 1 (AWG)', 'Wire 2 (AWG)', 'Ku (%)', 'Dmax (%)'};
xlswrite('Transformer.xlsx',table_title,'Range','A1:T1');

%{
%%% Annotation
str = {['Transformer core: EE' num2str(core_v(core))], ...
        ['K_{gfe} = ' num2str(Kgfe) ' cm^{beta}'], ...
        ['Efficiency = ' num2str(100*eta) ' %'], ...
        ['B_{op} = ' num2str(Bop) ' T'], ...
        ['dI_{L,max} = ' num2str(dIL_max) ' A'], ...
        ['I_{L,max} = ' num2str(IL_max) ' A'], ...
        ['I_{L,RMS} = ' num2str(IL_RMS) ' A'], ...
        ['I_{T1,max} = ' num2str(IT1_max) ' A'], ...
        ['I_{T1,RMS} = ' num2str(IT1_RMS) ' A'], ...
        ['dV_{O,max} = ' num2str(100*dVo_max) ' %'], ...
        ['N_1 = ' num2str(N1)], ...
        ['N_2 = ' num2str(N2)], ...
        ['L_m = ' num2str(1e6*Lm) ' mu H'], ...
        ['R_{T1} = ' num2str(RT1) ' Ohm'], ...
        ['R_{T2} = ' num2str(RT2) ' Ohm'], ...
        ['wire 1 = AWG' num2str(wire1)], ...
        ['wire 2 = AWG' num2str(wire2)], ...
        ['K_u = ' num2str(100*Ku) ' %'],
        ['Dmax = ' num2str(Dmax)]};
figure(1);
annotation('textbox',[0.3 0.5 0.3 0.3],'String',str,'FitBoxToText','on');
%}