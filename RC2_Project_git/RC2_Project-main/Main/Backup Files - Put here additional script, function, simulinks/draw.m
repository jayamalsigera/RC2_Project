function traj = draw(scale, v_des)

    %neonCyan = [0 0.8 1];
    %neonRed = [1 0.15 0.15];

    G = pacBoard();                      % 1=free, 0=wall
    wallHi = kron(G==0, ones(scale));    % 1=wall, 0=free
    [Hh, Wh] = size(wallHi);

    wallPlot = double(wallHi.');         % row->x, col->y

    fig = figure('Name','Draw trajectory (LMB=add, RMB=finish)', ...
                 'Color','k');
    ax = axes(fig); hold(ax,'on');

    imagesc(ax, [0 Hh], [0 Wh], wallPlot);
    set(ax,'YDir','normal');

    %customColormap = [neonCyan; 0 0 0];
    colormap(ax, gray(2));
    %colormap(ax, customColormap);
    clim(ax,[0 1]);

    axis(ax,'equal');
    xlim(ax,[0 Hh]); ylim(ax,[0 Wh]);
    axis(ax,'off');

    title(ax,'Draw trajectory (raw Cartesian coords)','Color','w');
    %title(ax,'Draw trajectory (raw Cartesian coords)','Color', neonCyan, 'FontWeight', 'bold');
    disp('Left-click to add points, right-click to finish.');

    xy = [];
    hLine = plot(ax, NaN, NaN, 'y-', 'LineWidth', 2);
    %hLine = plot(ax, NaN, NaN, '-o', 'Color', neonRed, ...
        %'MarkerFaceColor', neonRed, 'MarkerSize', 4, 'LineWidth', 2);

    % Definiamo una matrice 16x16 trasparente (NaN)
    %PointerCData = nan(16, 16);
    % Disegniamo una croce bianca (valore 1) al centro
    %PointerCData(8,:) = 1;     % Linea orizzontale
    %PointerCData(:,8) = 1;     % Linea verticale
    %PointerCData(9,:) = 1;
    %PointerCData(:,9) = 1;
    
    %set(fig, 'Pointer', 'custom', ...
             %'PointerShapeCData', PointerCData, ...
             %'PointerShapeHotSpot', [8 8]); % Il punto di click è il centro (8,8)
   

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

    % Calculate the distance between consecutive points
    d = sqrt(sum(diff(xy).^2,2));
    
    % Calculate time based on cumulative distance and constant velocity
    t = [0; cumsum(d)] / v_des;
    %t = [0; cumsum(d)];
    %t = t / t(end);

    traj.xy = xy; 
    traj.t  = t;

    save('trajectory.mat','traj');
    disp('Saved trajectory.mat');

    plot(ax, traj.xy(:,1), traj.xy(:,2), 'r--', 'LineWidth', 1.5);
    %plot(ax, traj.xy(:,1), traj.xy(:,2), '-', 'Color', neonRed, 'LineWidth', 2.5);

end
