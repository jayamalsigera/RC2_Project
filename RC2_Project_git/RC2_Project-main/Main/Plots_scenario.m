%% Initialization
clc; close all;


% Estrazione variabili da simOut (formato Timeseries)
% Usiamo il campo .Time per il tempo e .Data per i valori
time_sim   = tout;
q_data     = q.Data;
vw_data    = vw.Data;
vd_wd_data = vd_wd.Data;

% Colour for the plot
c_Act = '#0072BD'; % Blue for actual trajectory

%% Trajectory Tracking Phase ( t <= shift_time )
idx_traj = time_sim <= shift_time;

figure('Name', 'Trajectory Tracking', 'Position', [100, 100, 1200, 600]);

% --- Plot X-Y (Trajectory) ---
subplot(1, 2, 1); hold on; grid on;
plot(ref.Data(:, 1), ref.Data(:, 2), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Reference');
plot(q_data(idx_traj, 1), q_data(idx_traj, 2), 'Color', c_Act, 'LineWidth', 1.5, 'DisplayName', 'Trajectory');
title('XY Path - Trajectory Tracking');
xlabel('X [cm]'); ylabel('Y [cm]'); axis equal;
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Linear Velocity Plot ---
subplot(2, 2, 2); hold on; grid on;
plot(time_sim(idx_traj), vd_wd_data(idx_traj, 1), '--', 'Color', "k", 'LineWidth', 1, 'DisplayName', 'v_d');
plot(time_sim(idx_traj), vw_data(idx_traj, 1), '-', 'Color', c_Act, 'LineWidth', 1.5, 'DisplayName', ' v');
title('Linear Velocity'); ylabel('v [cm/s]'); 
xlim([0, shift_time]); % Limite bloccato alla fine del tracking
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Angular Velocity Plot ---
subplot(2, 2, 4); hold on; grid on;
plot(time_sim(idx_traj), vd_wd_data(idx_traj, 2), '--', 'Color', "k", 'LineWidth', 1, 'DisplayName', '\omega_d');
plot(time_sim(idx_traj), vw_data(idx_traj, 2), '-', 'Color', c_Act, 'LineWidth', 1.5, 'DisplayName', '\omega');
title('Angular Velocity'); xlabel('Time [s]'); ylabel('\omega [rad/s]'); 
xlim([0, shift_time]); % Limite bloccato alla fine del tracking
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));