%% Linear Trajectory Tracking Controller constants

a = 5;  % >0
xi = 0.71;  % (0,1)

%% Non linear Trajectory Tracking Controller constants

b = 5;  % >0
xi = 0.71;  % (0,1)

%% Simulation Variables

%shift_time = 3;  % trajectory tracking time (before regulation)
stop_time = 50;

scale = 15;
type = 'circle';

run('draw_scenarios(scale, type)');
uiwait(gcf);  % wait until figure is closed

%% desired trajectory generation
S = load('trajectory.mat');   % contains S.traj.xy and S.traj.t

% unicycle initial conditions
x0 = S.traj.xy(1,1);
y0 = S.traj.xy(1,2);
theta0 = -pi/2;

xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1] [belongs to (0,1)]

%Tfinal = shift_time;           % seconds
%t = t * Tfinal;

ref = timeseries(xy);      % ref.Data is Nx2: [x_d y_d]

assignin('base','ref', ref);

%% 4. Run Simulink Program and save results

model = 'L_tuning_2024b';

load_system(model);

set_param(model, 'StopTime', num2str(stop_time));
simOut = sim(model);

%% 5. Replay the saved data

run('replay_q_timeseries_on_maze.m');