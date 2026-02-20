%% 1. Initialization
scale = 50;
run('draw(scale)');
uiwait(gcf); 
run('mazeGUI(scale)');
uiwait(gcf);
run('simulation.m');
res = struct(); 

%% 2. Linear Trajectory Tracking

model1 = "L_Trajectory_Tracking_and_Regulation_2024b";
a = 5; xi = 0.706; % Parametri specifici
load_system(model1);
simOut1 = sim(model1, "StopTime", "10");

res.L.t = simOut1.tout;
res.L.q = simOut1.q.Data;
res.L.qdot = simOut1.qdot.Data;
res.L.ref = simOut1.xy_ref.Data;
res.L.v = simOut1.vw.Data(:,1);     
res.L.w = simOut1.vw.Data(:,2);
res.L.vd = simOut1.vd_wd.Data(:,1);
res.L.wd = simOut1.vd_wd.Data(:,2);

%% 3. Non-Linear 1

model2 = "NL_Trajectory_Tracking_and_Regularization_2024b";
% Assicurati che nl.b e nl_xi esistano nel workspace dopo simulation.m
load_system(model2);
set_param(model2, 'StopTime', num2str(stop_time));
simOut2 = sim(model2);

res.NL.t = simOut2.tout;
res.NL.q = simOut2.q.Data;
res.NL.qdot = simOut1.qdot.Data;
res.NL.ref = simOut2.xy_ref.Data; % Corretto typo simOut2
res.NL.v = simOut2.vw.Data(:,1);    
res.NL.w = simOut2.vw.Data(:,2);
res.NL.vd = simOut2.vd_wd.Data(:,1);
res.NL.wd = simOut2.vd_wd.Data(:,2);

%% 4. Non-Linear 2

model3 = "NL_Trajectory_Tracking_and_Posture_Regulation2_2024b";

load_system(model3);

simOut3 = sim(model3, 'StopTime', num2str(10));

res.NL2.t = simOut3.tout;
res.NL2.q = simOut3.q.Data;
res.NL2.qdot = simOut1.qdot.Data;
res.NL2.ref = simOut3.xy_ref.Data; 
res.NL2.v = simOut3.vw.Data(:,1);     
res.NL2.w = simOut3.vw.Data(:,2); 
res.NL2.vd = simOut3.vd_wd.Data(:,1);
res.NL2.wd = simOut3.vd_wd.Data(:,2);

%% 5. Plotting 

figure('Name', 'Confronto Performance', 'Color', 'w');
tlo = tiledlayout(4, 1, 'TileSpacing', 'compact');

% --- Trajectory ---
nexttile;
plot(res.L.ref(:,1), res.L.ref(:,2), 'b--', 'LineWidth', 2); hold on;
plot(res.L.q(:,1), res.L.q(:,2), 'r');
%plot(res.NL.q(:,1), res.NL.q(:,2), 'b');
plot(res.NL2.q(:,1), res.NL2.q(:,2), 'g');
grid on; axis equal; ylabel('Y [m]'); legend('Ref','L','NL1','NL2');

% --- Errors ---
nexttile;
plot(res.L.t, res.L.q(:,1) - res.L.ref(:,1), 'r'); hold on;
plot(res.L.t, res.L.q(:,2) - res.L.ref(:,2), 'r--'); hold on;
plot(res.NL.t, res.NL.q(:,1) - res.NL.ref(:,1), 'b');
plot(res.NL.t, res.NL.q(:,2) - res.NL.ref(:,2), 'b--'); hold on;
plot(res.NL2.t, res.NL2.q(:,1) - res.NL2.ref(:,1), 'g');
plot(res.NL2.t, res.NL2.q(:,2) - res.NL2.ref(:,2), 'g--'); hold on;
grid on; ylabel('Error X [m]');
title('XY errors');
legend('Lineare', 'NL1', 'NL2');

% --- acutated velocity ---
nexttile; 
plot(res.L.t, res.L.v, 'r'); hold on;
%plot(res.NL.t, res.NL.v, 'b');
plot(res.NL2.t, res.NL2.v, 'g');
grid on; ylabel('v [m/s]');

% --- actuated angular velocity ---
nexttile; 
plot(res.L.t, res.L.w, 'r'); hold on;
%plot(res.NL.t, res.NL.w, 'b');
plot(res.NL2.t, res.NL2.w, 'g');
grid on; ylabel('w [rad/s]'); xlabel('Time [s]');

%% 6. Save Data
save('results.mat', 'res'); 