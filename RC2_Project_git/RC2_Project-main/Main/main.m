% 1. Run draw.m and draw the required trajectory
% 2. Run mazeGUI.m to see the trajectory on the Maze
% 3. Run simulation.m for simulation intialization
% 4. Run Simulink Program and save results
% 5. Replay the saved results

scale = 50;

%% 1. Run draw.m and draw the required trajectory

run('draw(scale)');
uiwait(gcf);  % wait until figure is closed

%% 2. Run mazeGUI.m to see the trajectory on the Maze

run('mazeGUI(scale)');
uiwait(gcf);

%% 3. Run simulation.m for simulation intialization

run('simulation.m');

%% 4. Run Simulink Program and save results
model = 'NL_Trajectory_Tracking_and_Posture_Regulation2_2024b';

load_system(model);

set_param(model, 'StopTime', num2str(stop_time));
simOut = sim(model);

%% 5. Replay the saved data

run('replay_q_timeseries_on_maze.m');