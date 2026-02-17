function drawTrajectory(ax)

    trajFile = 'trajectory.mat';

    S = load(trajFile);
    xy = S.traj.xy;
    
    x = xy(:,1);
    y = xy(:,2);

    hold(ax,'on');
    plot(ax, x, y, ...
         'y-o', 'LineWidth', 2, ...
         'MarkerSize', 4, 'MarkerFaceColor','y');
end