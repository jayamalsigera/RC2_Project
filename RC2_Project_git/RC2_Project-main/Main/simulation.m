%% Linear Trajectory Tracking Controller constants
a = 3;  % >0
xi = 0.6;  % (0,1)

%% Non linear Trajectory Tracking Controller constants
b = 5;  % >0
xi = 0.6;  % (0,1)

%% Parking box pose
x_box     = 850;
y_box     = 880;
theta_box = 0;

%% Gains for posture regulation
k1 = 0.22;    
k2 = 1.0;     
k3 = 0.4;

%% Simulation Variables
%shift_time = 3;  % trajectory tracking time (before regulation)
stop_time = 30;

%% desired trajectory generation
S = load('trajectory.mat');   % contains S.traj.xy and S.traj.t

% unicycle initial conditions
x0 = S.traj.xy(1,1);
y0 = S.traj.xy(1,2);
theta0 = pi/4;

% last (x,y) to be tracked
last_traj = S.traj.xy(end,:);
assignin('base','last_traj', last_traj);

xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1] [belongs to (0,1)]

%Tfinal = shift_time;           % seconds
%t = t * Tfinal;

ref = timeseries(xy);      % ref.Data is Nx2: [x_d y_d]

assignin('base','ref', ref);