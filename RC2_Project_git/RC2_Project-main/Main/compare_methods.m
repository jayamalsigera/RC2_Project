%% 1. Initialization

scale = 50;
Ts = 0.001;
v_des = 50;

run('draw(scale, v_des)');
uiwait(gcf); 
run('mazeGUI(scale)');
uiwait(gcf);
run('simulation.m');

res = struct(); 

%% 2. Linear 

model1 = "L_Trajectory_Tracking_and_Regulation_2024b";
a = 5; xi = 0.706; % gains parameters

load_system(model1);
simOut1 = sim(model1, "StopTime", num2str(stop_time));

% time
res.L.t = simOut1.tout;

% q - qdot
res.L.q = simOut1.q.Data;
res.L.qdot = simOut1.qdot.Data;

% acutation variables
res.L.v = simOut1.vw.Data(:,1);     
res.L.w = simOut1.vw.Data(:,2);

% desired input
res.L.vd = simOut1.vd_wd.Data(:,1);
res.L.wd = simOut1.vd_wd.Data(:,2);

% controller parameters
res.L.a = a;
res.L.xi = xi;

%% 3. Non-Linear 1

model2 = "NL_Trajectory_Tracking_and_Regularization_2024b";
b = 5; xi = 0.706;  % gains paramaters

load_system(model2);
simOut2 = sim(model2, 'StopTime', num2str(stop_time));

% time
res.NL.t = simOut2.tout;

% q - qdot
res.NL.q = simOut2.q.Data;
res.NL.qdot = simOut1.qdot.Data;

% actuation variables
res.NL.v = simOut2.vw.Data(:,1);    
res.NL.w = simOut2.vw.Data(:,2);

% desired input
res.NL.vd = simOut2.vd_wd.Data(:,1);
res.NL.wd = simOut2.vd_wd.Data(:,2);

% controller parameters
res.NL.b = b;
res.NL.xi = xi;

%% 4. Non-Linear 2

model3 = "NL_Trajectory_Tracking_and_Posture_Regulation2_2024b";
b = 5; xi = 0.706; % gains parameters

load_system(model3);
simOut3 = sim(model3, 'StopTime', num2str(stop_time));

% time
res.NL2.t = simOut3.tout;

% q - qdot
res.NL2.q = simOut3.q.Data;
res.NL2.qdot = simOut1.qdot.Data;

% actuation variables
res.NL2.v = simOut3.vw.Data(:,1);     
res.NL2.w = simOut3.vw.Data(:,2); 

% desired input
res.NL2.vd = simOut3.vd_wd.Data(:,1);
res.NL2.wd = simOut3.vd_wd.Data(:,2);

% controller variables
res.NL2.b = b;
res.NL2.xi = xi;

%% 6. Save Data

run('replay_q_timeseries_on_mazes.m');
save('results.mat', 'res'); 