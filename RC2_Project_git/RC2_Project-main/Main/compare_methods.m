%% Initialization

Ts = 0.001;
v_des = 200;

% Trajectory Tracking Gains Parameters
load("Lin_Traj_params.mat")
load("NonLin_Traj_params.mat")

% Regulation Gains
load("Cartesian_gains.mat")
load("Posture_gains.mat")

% Parking Box coords
load("parking_box.mat")

% --- LOAD HERE THE TRAJECTORY ---
S = load('trajectory_dense.mat');   % contains S.traj.xy and S.traj.t

% unicycle initial conditions
x0 = S.traj.xy(1,1);
y0 = S.traj.xy(1,2);
theta0 = pi/4;
xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1]

% simulation times
shift_time = t(end);  % time traj2reg
stop_time = t(end) + 5;  % stop simulation
ref = timeseries(xy, t);      % ref.Data is Nx2: [x_d y_d]
assignin('base','ref', ref);

% Inizialization Results struct
res = struct(); 

%% Linear 

model1 = "L_Trajectory_Tracking_and_Cartesian_Regulation";
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

%% Linear 2

model2 = "L_Trajectory_Tracking_and_Posture_Regulation";
load_system(model2);
simOut2 = sim(model2, 'StopTime', num2str(stop_time));

% time
res.L2.t = simOut2.tout;

% q - qdot
res.L2.q = simOut2.q.Data;
res.L2.qdot = simOut2.qdot.Data;

% actuation variables
res.L2.v = simOut2.vw.Data(:,1);     
res.L2.w = simOut2.vw.Data(:,2); 

% desired input
res.L2.vd = simOut2.vd_wd.Data(:,1);
res.L2.wd = simOut2.vd_wd.Data(:,2);

% controller variables
res.L2.b = b;
res.L2.xi = xi;


%% Non-Linear 

model3 = "NL_Trajectory_Tracking_and_Cartesian_Regulation";
load_system(model3);
simOut3 = sim(model3, 'StopTime', num2str(stop_time));

% time
res.NL.t = simOut3.tout;

% q - qdot
res.NL.q = simOut3.q.Data;
res.NL.qdot = simOut3.qdot.Data;

% actuation variables
res.NL.v = simOut3.vw.Data(:,1);    
res.NL.w = simOut3.vw.Data(:,2);

% desired input
res.NL.vd = simOut3.vd_wd.Data(:,1);
res.NL.wd = simOut3.vd_wd.Data(:,2);

% controller parameters
res.NL.b = b;
res.NL.xi = xi;

%% Non-Linear 2

model4 = "NL_Trajectory_Tracking_and_Posture_Regulation";
load_system(model4);
simOut4 = sim(model4, 'StopTime', num2str(stop_time));

% time
res.NL2.t = simOut4.tout;

% q - qdot
res.NL2.q = simOut4.q.Data;
res.NL2.qdot = simOut4.qdot.Data;

% actuation variables
res.NL2.v = simOut4.vw.Data(:,1);     
res.NL2.w = simOut4.vw.Data(:,2); 

% desired input
res.NL2.vd = simOut4.vd_wd.Data(:,1);
res.NL2.wd = simOut4.vd_wd.Data(:,2);

% controller variables
res.NL2.b = b;
res.NL2.xi = xi;

%% Save Data

save('results.mat', 'res'); 

%% Show Plots

Plots_compare