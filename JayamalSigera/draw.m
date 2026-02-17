function traj = draw(scale)
    G = pacBoard();                      % 1=free, 0=wall
    wallHi = kron(G==0, ones(scale));    % 1=wall, 0=free
    [Hh, Wh] = size(wallHi);

    wallPlot = double(wallHi.');         % row->x, col->y

    fig = figure('Name','Draw trajectory (LMB=add, RMB=finish)', ...
                 'Color','k');
    ax = axes(fig); hold(ax,'on');

    imagesc(ax, [0 Hh], [0 Wh], wallPlot);
    set(ax,'YDir','normal');
    colormap(ax, gray(2));
    caxis(ax,[0 1]);

    axis(ax,'equal');
    xlim(ax,[0 Hh]); ylim(ax,[0 Wh]);
    axis(ax,'off');

    title(ax,'Draw trajectory (raw Cartesian coords)','Color','w');
    disp('Left-click to add points, right-click to finish.');

    xy = [];
    hLine = plot(ax, NaN, NaN, 'y-', 'LineWidth', 2);

    while true
        [x,y,btn] = ginput(1);

        if isempty(btn) || btn ~= 1
            break;
        end

        x = min(max(x, 0), Hh);
        y = min(max(y, 0), Wh);

        xy(end+1,:) = [x y];
        set(hLine,'XData',xy(:,1),'YData',xy(:,2));
        drawnow;
    end

    if size(xy,1) < 2
        error('Trajectory too short.');
    end

    xy = unique(xy,'rows','stable');

    d = sqrt(sum(diff(xy).^2,2));
    t = [0; cumsum(d)];
    t = t / t(end);

    traj.xy = xy;
    traj.t  = t;

    save('trajectory.mat','traj');
    disp('Saved trajectory.mat');

    plot(ax, traj.xy(:,1), traj.xy(:,2), 'r--', 'LineWidth', 1.5);
end
