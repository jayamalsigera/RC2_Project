%% 1. Inizializzazione e Caricamento Dati
clc; close all;

% Carica i risultati salvati in precedenza
S = load('trajectory.mat');
xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1] 
Tfinal = shift_time;           % seconds
t = t * Tfinal;
ref = timeseries(xy, t); 

load('results.mat', 'res'); 


% Colori per i grafici per mantenere coerenza
cL  = '#0072BD'; % Blu per Lineare
cNL = '#D95319'; % Rosso per Non-Lineare 1
cNL2= '#EDB120'; % Giallo per Non-Lineare 2

%% 2. FASE 1: Trajectory Tracking ( t <= shift_time )
disp('Generazione grafici Trajectory Tracking...');

% Indici logici per il tempo
idx_L_traj  = res.L.t <= shift_time;
idx_NL_traj = res.NL.t <= shift_time;
idx_NL2_traj= res.NL2.t <= shift_time;

figure('Name', 'Trajectory Tracking Phase', 'Position', [100, 100, 1200, 600]);
%% 1. Inizializzazione e Caricamento Dati
clc; close all;

% Carica i risultati salvati in precedenza
S = load('trajectory.mat');
xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1] 
Tfinal = shift_time;          % seconds
t = t * Tfinal;
ref = timeseries(xy, t); 

load('results.mat', 'res'); 

% Colori per i grafici per mantenere coerenza
cL  = '#0072BD'; % Blu per Lineare
cNL = '#D95319'; % Rosso per Non-Lineare 1
cNL2= '#EDB120'; % Giallo per Non-Lineare 2

%% 2. FASE 1: Trajectory Tracking ( t <= shift_time )
disp('Generazione grafici Trajectory Tracking...');

% Indici logici per il tempo
idx_L_traj  = res.L.t <= shift_time;
idx_NL_traj = res.NL.t <= shift_time;
idx_NL2_traj= res.NL2.t <= shift_time;

figure('Name', 'Trajectory Tracking Phase', 'Position', [100, 100, 1200, 600]);

% --- Plot X-Y (Percorso) ---
subplot(1, 2, 1);
hold on; grid on;
% Plot del percorso di riferimento se desiderato:
plot(ref.Data(:, 1), ref.Data(:, 2), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Reference');
plot(res.L.q(idx_L_traj, 1), res.L.q(idx_L_traj, 2), 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear');
plot(res.NL.q(idx_NL_traj, 1), res.NL.q(idx_NL_traj, 2), 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL 1');
plot(res.NL2.q(idx_NL2_traj, 1), res.NL2.q(idx_NL2_traj, 2), 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL 2');
title('XY Path - Trajectory Tracking');
xlabel('X [m]'); ylabel('Y [m]');
legend('Location', 'best');
axis equal;

% --- Plot Velocità di Controllo Lineare (v e vd) ---
subplot(2, 2, 2);
hold on; grid on;
% Desiderate (vd) - tratteggiate
plot(res.L.t(idx_L_traj), res.L.vd(idx_L_traj), '--', 'Color', cL, 'LineWidth', 1, 'DisplayName', 'Linear v_d');
plot(res.NL.t(idx_NL_traj), res.NL.vd(idx_NL_traj), '--', 'Color', cNL, 'LineWidth', 1, 'DisplayName', 'NL 1 v_d');
plot(res.NL2.t(idx_NL2_traj), res.NL2.vd(idx_NL2_traj), '--', 'Color', cNL2, 'LineWidth', 1, 'DisplayName', 'NL 2 v_d');
% Attuali (v) - continue
plot(res.L.t(idx_L_traj), res.L.v(idx_L_traj), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear v');
plot(res.NL.t(idx_NL_traj), res.NL.v(idx_NL_traj), '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL 1 v');
plot(res.NL2.t(idx_NL2_traj), res.NL2.v(idx_NL2_traj), '-', 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL 2 v');
title('Linear Velocity (v, v_d)');
xlabel('Time [s]'); ylabel('v [m/s]');
% Per non affollare il grafico, mostriamo solo le attuali in legenda
legend({'Linear v', 'NL 1 v', 'NL 2 v'}, 'Location', 'best'); 

% --- Plot Velocità di Controllo Angolare (w e wd) ---
subplot(2, 2, 4);
hold on; grid on;
% Desiderate (wd) - tratteggiate
plot(res.L.t(idx_L_traj), res.L.wd(idx_L_traj), '--', 'Color', cL, 'LineWidth', 1);
plot(res.NL.t(idx_NL_traj), res.NL.wd(idx_NL_traj), '--', 'Color', cNL, 'LineWidth', 1);
plot(res.NL2.t(idx_NL2_traj), res.NL2.wd(idx_NL2_traj), '--', 'Color', cNL2, 'LineWidth', 1);
% Attuali (w) - continue
plot(res.L.t(idx_L_traj), res.L.w(idx_L_traj), '-', 'Color', cL, 'LineWidth', 1.5);
plot(res.NL.t(idx_NL_traj), res.NL.w(idx_NL_traj), '-', 'Color', cNL, 'LineWidth', 1.5);
plot(res.NL2.t(idx_NL2_traj), res.NL2.w(idx_NL2_traj), '-', 'Color', cNL2, 'LineWidth', 1.5);
title('Angular Velocity (\omega, \omega_d)');
xlabel('Time [s]'); ylabel('\omega [rad/s]');


%% 3. FASE 2: Posture Regulation ( t > shift_time )
disp('Generazione grafici Posture Regulation...');

% Indici logici per il tempo di regulation
idx_L_reg  = res.L.t > shift_time;
idx_NL_reg = res.NL.t > shift_time;
idx_NL2_reg= res.NL2.t > shift_time;

figure('Name', 'Posture Regulation Phase', 'Position', [150, 150, 1200, 800]);

% --- Plot X-Y (Percorso verso il Box) ---
subplot(1, 2, 1);
hold on; grid on;
plot(x_box, y_box, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k', 'DisplayName', 'Target Box');
plot(res.L.q(idx_L_reg, 1), res.L.q(idx_L_reg, 2), 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear');
plot(res.NL.q(idx_NL_reg, 1), res.NL.q(idx_NL_reg, 2), 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL 1');
plot(res.NL2.q(idx_NL2_reg, 1), res.NL2.q(idx_NL2_reg, 2), 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL 2');
title('XY Path - Regulation to Box');
xlabel('X [m]'); ylabel('Y [m]');
legend('Location', 'best');
axis equal;

% --- Plot Errore Distanza ---
subplot(3, 2, 2);
hold on; grid on;
dist_L = sqrt((res.L.q(idx_L_reg, 1) - x_box).^2 + (res.L.q(idx_L_reg, 2) - y_box).^2);
dist_NL = sqrt((res.NL.q(idx_NL_reg, 1) - x_box).^2 + (res.NL.q(idx_NL_reg, 2) - y_box).^2);
dist_NL2 = sqrt((res.NL2.q(idx_NL2_reg, 1) - x_box).^2 + (res.NL2.q(idx_NL2_reg, 2) - y_box).^2);

plot(res.L.t(idx_L_reg), dist_L, '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear');
plot(res.NL.t(idx_NL_reg), dist_NL, '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL 1');
plot(res.NL2.t(idx_NL2_reg), dist_NL2, '-', 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL 2');
title('Distance Error to Target');
ylabel('Distance [m]');
legend('Location', 'best');

% --- Plot Velocità Lineare (v e vd) ---
subplot(3, 2, 4);
hold on; grid on;
% Attuali (v) - continue
plot(res.L.t(idx_L_reg), res.L.v(idx_L_reg), '-', 'Color', cL, 'LineWidth', 1.5);
plot(res.NL.t(idx_NL_reg), res.NL.v(idx_NL_reg), '-', 'Color', cNL, 'LineWidth', 1.5);
plot(res.NL2.t(idx_NL2_reg), res.NL2.v(idx_NL2_reg), '-', 'Color', cNL2, 'LineWidth', 1.5);
title('Linear Velocity v - regulation');
ylabel('v [m/s]');

% --- Plot Velocità Angolare (w e wd) ---
subplot(3, 2, 6);
hold on; grid on;
% Attuali (w) - continue
plot(res.L.t(idx_L_reg), res.L.w(idx_L_reg), '-', 'Color', cL, 'LineWidth', 1.5);
plot(res.NL.t(idx_NL_reg), res.NL.w(idx_NL_reg), '-', 'Color', cNL, 'LineWidth', 1.5);
plot(res.NL2.t(idx_NL2_reg), res.NL2.w(idx_NL2_reg), '-', 'Color', cNL2, 'LineWidth', 1.5);
title('Angular Velocity \omega - regulation');
xlabel('Time [s]'); ylabel('\omega [rad/s]');

disp('Grafici completati.');