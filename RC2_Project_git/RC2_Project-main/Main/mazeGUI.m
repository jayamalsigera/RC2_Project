function mazeGUI(scale)
    
    neonCyan = [0 0.8 1];

    % Base binary grid
    G = pacBoard();

    % Scale up
    wallHi = kron(G==0, ones(scale));
    [Hh, Wh] = size(wallHi);

    % row->x, col->y
    wallPlot = wallHi.';

    % Boundaries
    B = bwboundaries(wallPlot, 4);  % store visual boundaries
    wallsXY = boundariesToXY(B); % create visual boundaries

    % Plot
    figure('Color','k'); ax = axes; hold(ax,'on');

    % transpose: x-range=[0,Hh], y-range=[0,Wh]
    image(ax, [0 Hh], [0 Wh], wallPlot);
    set(ax,'YDir','normal');

    customColormap = [0 0 0; neonCyan];
    colormap(ax, customColormap);
    %colormap(ax, gray);
    clim(ax, [0 1]);

    axis(ax,'equal'); axis(ax,'tight'); axis(ax,'off');

    % Overlay boundaries
    plot(ax, wallsXY(:,1), wallsXY(:,2), '-', 'Color', neonCyan, 'LineWidth', 2);
    % plot(ax, wallsXY(:,1), wallsXY(:,2), 'b-', 'LineWidth', 2);

    drawTrajectory(ax);

    %title(ax, sprintf('Maze'), 'Color','w');
    title(ax, sprintf('Maze'), 'Color', neonCyan, 'FontWeight', 'bold');

    assignin('base','wallPlot',wallPlot);
    assignin('base','Hh',Hh);
    assignin('base','Wh',Wh);
    assignin('base','scale',scale);
end



