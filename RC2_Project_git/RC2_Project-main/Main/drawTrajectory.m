function drawTrajectory(ax)
    
    neonRed = [1 0.15 0.15];

    trajFile = 'trajectory.mat';

    S = load(trajFile);
    xy = S.traj.xy;
    
    x = xy(:,1);
    y = xy(:,2);

    hold(ax,'on');
    plot(ax, x, y, ...
         '-o', 'Color', neonRed, 'LineWidth', 2, ...
         'MarkerSize', 4, 'MarkerFaceColor', neonRed, 'MarkerEdgeColor', neonRed);
    %plot(ax, x, y, ...
        %'y-o', 'LineWidth', 2, ...
        % 'MarkerSize', 4, 'MarkerFaceColor','y');
end