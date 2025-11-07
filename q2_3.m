%% Q2 & Q3  (Daniel Tyukov, thetaA=99 deg)
clear; close all; clc;

deg = pi/180;

quant2bit = @(ang) round(ang/(90*deg))*(90*deg);
psi = @(th) pi*sind(th);

% q1
thetaA = 99;
psiA = psi(thetaA);
phi1 = -psiA;
phi2 = -psiA;
phi3 = -2*psiA;

% 2-bit
phi1q = quant2bit(phi1);
phi2q = quant2bit(phi2);
phi3q = quant2bit(phi3);

% sweep
thetaB = 0:0.1:90;
psiB   = psi(thetaB);

% Array response to angle for port 5
g5  = 0.5*( ...
      1 ...
    + exp(1j*(phi1 + psiB)) ...
    + exp(1j*(phi3 + 2*psiB)) ...
    + exp(1j*(phi3 + phi2 + 3*psiB)) );

g5q = 0.5*( ...
      1 ...
    + exp(1j*(phi1q + psiB)) ...
    + exp(1j*(phi3q + 2*psiB)) ...
    + exp(1j*(phi3q + phi2q + 3*psiB)) );

% A at port 5 is constant vs angles:
g5_A = 0.5*(1 + exp(1j*(phi1 + psiA)) + exp(1j*(phi3 + 2*psiA)) + exp(1j*(phi3 + phi2 + 3*psiA)));
G5_A_dB  = 20*log10(abs(g5_A));
G5_B_dB  = 20*log10(abs(g5));
G5_Bq_dB = 20*log10(abs(g5q));

% normalizing
normRef = 20*log10(2);
G5_A_dB  = G5_A_dB  - normRef;
G5_B_dB  = G5_B_dB  - normRef;
G5_Bq_dB = G5_Bq_dB - normRef;

%  phi4, phi5 for each theta B
S12 = 1 + exp(1j*(phi1 + psiB));
S34 = exp(1j*2*psiB) + exp(1j*(phi2 + 3*psiB));
phi4 = angle(S12) - angle(S34);
phi4 = mod(phi4 + pi, 2*pi) - pi;
phi5 = zeros(size(phi4));

figure; 
plot(thetaB, G5_B_dB, 'LineWidth',1.6); hold on;
plot(thetaB, G5_Bq_dB, '--', 'LineWidth',1.6);
yline(G5_A_dB, ':', sprintf('A at port 5 = %.2f dB', G5_A_dB),'LabelVerticalAlignment','bottom');
grid on; xlabel('\theta_B (deg)'); ylabel('Normalized Gain at port 5 (dB)');
title('Port 5 gain: B vs \theta_B  (solid), 2-bit blue phases (dashed), A is horizontal line');
legend('B @ port 5 (continuous phases)','B @ port 5 (2-bit phases)','Location','best');

figure;
yyaxis left; plot(thetaB, phi4/deg, 'LineWidth',1.6); ylabel('\phi_4 (deg)');
yyaxis right; plot(thetaB, phi5/deg, '--', 'LineWidth',1.6); ylabel('\phi_5 (deg)');
grid on; xlabel('\theta_B (deg)'); title('\phi_4 and \phi_5 required to focus B at port 6');
legend('\phi_4 (align subarrays)','\phi_5 (final align; 0^\circ with 0^\circ combiners)','Location','best');

disp('First 10 samples of phi4, phi5 (degrees) vs thetaB:');
T = table(thetaB(1:10).', (phi4(1:10)/deg).', (phi5(1:10)/deg).', ...
          'VariableNames', {'thetaB_deg','phi4_deg','phi5_deg'});
disp(T);
