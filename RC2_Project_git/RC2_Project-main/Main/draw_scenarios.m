function traj = draw_scenarios(scale, type)
    if nargin < 2, type = 'circle'; end % Default se non specificato

    G = blankBoard();                      
    wallHi = kron(G==0, ones(scale));    
    [Hh, Wh] = size(wallHi);
    wallPlot = double(wallHi.');         
    
    % Setup Grafico
    fig = figure('Name', ['Scenario: ', type], 'Color', 'k');
    ax = axes(fig); hold(ax, 'on');
    imagesc(ax, [0 Hh], [0 Wh], wallPlot);
    set(ax, 'YDir', 'normal');
    colormap(ax, gray(2));
    axis(ax, 'equal'); axis(ax, 'off');

    % Coordinate del centro e dimensioni
    cx = Hh / 2; cy = Wh / 2;
    
    switch lower(type)
        case 'line'
            % LINEA RETTA: 400 punti da sinistra a destra
            x = linspace(Hh*0.1, Hh*0.9, 400)';
            y = ones(400, 1) * cy;
            xy = [x, y];
            
        case 'circle'
            % CERCHIO: raggio 35% della mappa
            R = min(Hh, Wh) * 0.35;
            theta = linspace(0, 2*pi, 400)';
            xy = [cx + R*cos(theta), cy + R*sin(theta)];
            
        case 'square'
            % QUADRATO: perimetro con angoli vivi
            side = min(Hh, Wh) * 0.6;
            s2 = side/2;
            % Definizione vertici
            pts = [cx-s2, cy-s2;  % Bottom-left
                   cx+s2, cy-s2;  % Bottom-right
                   cx+s2, cy+s2;  % Top-right
                   cx-s2, cy+s2;  % Top-left
                   cx-s2, cy-s2]; % Chiusura
            
            % Interpolazione per avere 400 punti totali (100 per lato)
            xy = [];
            for i = 1:4
                seg_x = linspace(pts(i,1), pts(i+1,1), 101)';
                seg_y = linspace(pts(i,2), pts(i+1,2), 101)';
                xy = [xy; [seg_x(1:100), seg_y(1:100)]];
            end
            
        otherwise
            error('Tipo scenario non valido. Usa: line, circle o square.');
    end

    % Calcolo tempo normalizzato
    d = sqrt(sum(diff(xy).^2, 2));
    t = [0; cumsum(d)];
    t = t / t(end);
    
    traj.xy = xy; 
    traj.t  = t;
    
    save('trajectory.mat', 'traj');

    assignin('base', 'wallPlot', wallPlot);
    assignin('base', 'scenario', xy);
    assignin('base', 'Hh', Hh);
    assignin('base', 'Wh', Wh);

    plot(ax, traj.xy(:,1), traj.xy(:,2), 'r-', 'LineWidth', 2);
    title(ax, ['Tuning Scenario: ', upper(type)], 'Color', 'w');
    disp(['Salvato trajectory.mat per scenario: ', type]);


end