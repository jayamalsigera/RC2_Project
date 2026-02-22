%% Linear Trajectory Tracking Controller constants

a = 5;  % >0
xi = 0.71;  % (0,1)

%% Non linear Trajectory Tracking Controller constants

b = 50;  % >0
xi = 0.71;  % (0,1)

%% Simulation Variables

%shift_time = 15;  % trajectory tracking time (before regulation)

scale = 15;
v_des = 50;
type = 'line';

run('draw_simply_scenarios(scale, type, v_des)');
uiwait(gcf);  % wait until figure is closed

%% desired trajectory generation
S = load('trajectory.mat');   % contains S.traj.xy and S.traj.t

% unicycle initial conditions
x0 = S.traj.xy(1,1);
y0 = S.traj.xy(1,2);
theta0 = pi/4;

xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1] [belongs to (0,1)]

%Tfinal = shift_time;           % seconds
%t = t * Tfinal;

shift_time = t(end);

ref = timeseries(xy, t);      % ref.Data is Nx2: [x_d y_d]

assignin('base','ref', ref);

%% 4. Run Simulink Program and save results

Ts = 0.001;
model = 'NL_tuning';

load_system(model);

set_param(model, 'StopTime', num2str(shift_time));
simOut = sim(model);

%% 5. Replay the saved data

run('replay_q_timeseries_on_scenario_pacman(type)');