%% Q4–Q6  (Daniel Tyukov, thetaA=99 deg)
clear; close all; clc;

deg = pi/180;

% helpers
quant2bit = @(ang) round(ang/(90*deg))*(90*deg);
psi      = @(th) pi*sind(th);
wrapPi   = @(x) mod(x+pi,2*pi)-pi;

% q1 (blue phases focus A to port 5)
thetaA = 99;
psiA   = psi(thetaA);
phi1   = -psiA;
phi2   = -psiA;
phi3   = -2*psiA;

% sweep
thetaB = 0:0.1:90;
psiB   = psi(thetaB);

% subarrays feeding red network
S12 = 1 + exp(1j*(phi1 + psiB));
S34 = exp(1j*2*psiB) + exp(1j*(phi2 + 3*psiB));

% port 6 gain (continuous red phases)
phi4 = wrapPi(angle(S12) - angle(S34));
phi5 = 0;
g6_cont = 0.5*( S12 + exp(1j*phi4).*S34 );

% 2-bit red phases
phi4_2b = quant2bit(phi4);
phi5_2b = quant2bit(phi5);
g6_2bit = 0.5*( S12 + exp(1j*phi4_2b).*S34 );

% normalize
normRef     = max(abs(g6_cont));
G6_cont_dB  = 20*log10(abs(g6_cont)/normRef);
G6_2bit_dB  = 20*log10(abs(g6_2bit)/normRef);

figure('Name','Q4–Q5: Port 6 vs \theta_B');
plot(thetaB, G6_cont_dB, 'LineWidth',1.8); hold on;
plot(thetaB, G6_2bit_dB, '--', 'LineWidth',1.8);
grid on; xlabel('\theta_B (deg)'); ylabel('Normalized Gain at port 6 (dB)');
title('Port 6 gain for B: continuous (solid) vs 2-bit red (dashed)');
legend('continuous','2-bit red','Location','best');

etas = [0.20 0.35 0.50 0.65 0.80];
figure('Name','Q6: variable power-ratio coupler');
hold on;
for eta = etas
    g6_eta    = sqrt(eta)*S12 + sqrt(1-eta)*exp(1j*phi4).*S34;
    G6_eta_dB = 20*log10(abs(g6_eta)/normRef);
    plot(thetaB, G6_eta_dB, 'LineWidth',1.4, ...
        'DisplayName', sprintf('\\eta=%.2f', eta));
end
grid on; xlabel('\theta_B (deg)'); ylabel('Normalized Gain at port 6 (dB)');
title('Port 6 gain for B with variable power-ratio final coupler');
legend('Location','best');

probe = [0 10 20 30 40 60 80 90];
[~,ix] = ismember(probe, round(thetaB,1));
T = table(probe.', G6_cont_dB(ix).', G6_2bit_dB(ix).', ...
    'VariableNames', {'thetaB_deg','G6_cont_dB','G6_2bit_dB'});
disp('Sample values (dB) at selected angles:');
disp(T);
