function [PT, IT1_max, IT1_med, IT1_RMS, Lm, ILm, N1, ...
    N2, Kgfe, Aw1, Aw2, Bop, Ku, wire1, wire2, RT1, RT2] ...
= transformer_design (core, n, eta, Ts, Vo_max, Po_max, ...
    IL_max, IL_min, Dmax)
%%% Material F magnetic properties (Bsat = 470 mT)
beta = 2.68;
Kfe = 57.3; % W / (cm3 * T^beta)
mu_F = 2.9723e-3; % H / m
%{
mu_F = (3008 +0.2825*(fs/1e3) -0.02084*(fs/1e3)^2 +1.894e-4*(fs/1e3)^3 ...
    -5.040e-7*(fs/1e3)^4 +5.753e-10*(fs/1e3)^5 -2.988e-13*(fs/1e3)^6 ...
    +5.802e-17*(fs/1e3)^7) * 1e-6; % H / m
%}

%%% Transformer electrical properties
rho = 1.68e-6; % Ohm * cm
ILm = 0.1 * IL_max / n; % A
Ku_ref = 0.3;
Ku = Ku_ref;
PT = 0.01 * Po_max; % W

%%% Electric variables
IT1_med = IL_min / n;
IT2_RMS = sqrt(Dmax*(IL_max^2 + IL_max*IL_min + IL_min^2)/3);
lamb1 = n * Ts * Vo_max / eta;

%%% Transformer core geometrical properties (EE12 to EE70)
Ac_v = [0.14, 0.19, 0.23, 0.41, 1.09, ...
    1.27, 2.26, 2.47, 3.24]; % cm2
Wa_v = [0.085, 0.19, 0.284, 0.196, 0.476, ...
    1.1, 1.78, 2.89, 6.75]; % cm2
MLT_v = [2.28, 3.4, 3.69, 3.99, 6.6, 8.5, 10, 12.8, 14]; % cm
lm_v = [2.7, 3.45, 3.94, 3.96, 5.77, 7.7, 9.58, 11, 18]; % cm
Ac = Ac_v(core);
Wa = Wa_v(core);
MLT = MLT_v(core);
lm = lm_v(core);

%%% Wire properties (AWG0 to AWG24)
wire_v = 0 : 1 : 44;
Aw_v = [534.8, 424.1, 336.3, 266.7, 211.5, 167.7, 133, ...
    105.5, 83.67, 66.32, 52.41, 41.6, 33.08, 26.26, 20.02, ...
    16.51, 13.07, 10.39, 8.228, 6.531, 5.188, 4.116, 3.243, ...
    2.508, 2.047, 1.623, 1.28, 1.021, 0.8046, 0.647, 0.5067, ...
    0.4013, 0.3242, 0.2554, 0.2011, 0.1589, 0.1266, 0.1026, ...
    0.08107, 0.06207, 0.04869, 0.03972, 0.03166, 0.02452, ...
    0.0202] * 1e-3; % cm2
rw_v = [3.224, 4.065, 5.128, 6.463, 8.153, 10.28, 13, 16.3, ...
    20.6, 26, 32.9, 41.37, 52.09, 69.64, 82.8, 104.3, 131.8, ...
    165.8, 209.5, 263.9, 332.3, 418.9, 531.4, 666, 842.1, ...
    1062, 1345, 1687.6, 2142.7, 2664.3, 3402.2, 4294.6, ...
    5314.9, 6748.6, 8572.8, 10849, 13608, 16801, 21266, ...
    27775, 35400, 43405, 54429, 70308, 85072] * 1e-6; % Ohm / cm
cw = length(wire_v);

%%% Transformer design
re = 0.01; % relative error percent
ite_max = 50; % maximum iteration
rel_er = 1;
ite = 0;
while ((rel_er>re) && (ite<ite_max))
    ILm_b = ILm;
    PT_b = PT;
    
    IT1_max = IL_max / n + ILm;
    IT1_RMS = sqrt(Dmax * (IT1_max^2 + ...
        IT1_max*IT1_med + IT1_med^2 + ILm^2) / 3);
    I_RMS_t1 = IT1_RMS + IT2_RMS / n;
    
    Kgfe = 1e8 * rho * lamb1^2 * I_RMS_t1^2 * Kfe^(2/beta) ...
        / (4 * Ku * PT^(1+2/beta));
    
    Bop = (1e8 * rho * lamb1^2 * I_RMS_t1^2 * MLT / ...
        (2 * Ku * Wa * Ac^3 * lm * beta * Kfe)) ^ (1/(beta+2));
    
    N1 = lamb1 / (2 * Bop * Ac) * 1e4;
    N1 = n * round(N1/n);
    N2 = N1 / n;
    
    Aw1 = Ku_ref * Wa * IT1_RMS / (N1 * I_RMS_t1);
    pos1 = 1;
    while ((Aw_v(pos1)>Aw1) && (pos1<cw))
        pos1 = pos1 + 1;
    end
    Aw1 = Aw_v(pos1);
    
    Aw2 = Ku_ref * Wa * IT2_RMS / (N1 * I_RMS_t1);
    pos2 = 1;
    while ((Aw_v(pos2)>Aw2) && (pos2<cw))
        pos2 = pos2 + 1;
    end
    Aw2 = Aw_v(pos2);
    
    Ku = (N1*Aw1 + N2*Aw2) / Wa;
    PT = Kfe * Bop^beta * Ac * lm + ...
        rho * MLT * N1^2 * I_RMS_t1^2 / (Wa * Ku);
    Lm = mu_F * N1^2 * Ac * 1e-2 / lm;
    ILm = Ts * n * Vo_max / (eta * Lm);
    
    ite = ite + 1;
    rel_er = max(abs([1-ILm/ILm_b, 1-PT/PT_b])) * 100;
end

IT1_max = IL_max / n + ILm;
IT1_RMS = sqrt(Dmax*(IT1_max^2 + IT1_max*IT1_med + ...
    IT1_med^2 + ILm^2)/3);

wire1 = wire_v(pos1);
RT1 = rw_v(pos1) * N1 * MLT;

wire2 = wire_v(pos2);
RT2 = rw_v(pos2) * N2 * MLT;