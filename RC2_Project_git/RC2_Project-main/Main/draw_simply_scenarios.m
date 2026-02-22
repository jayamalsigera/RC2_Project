function draw_simply_scenarios(scale, type, v_des)
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
            % LINEA RETTA: 50 punti da sinistra a destra
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
            
            % Interpolazione per avere 50 punti totali (100 per lato)
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
    t = [0; cumsum(d)] / v_des;
    %t = t / t(end);
    
    traj.xy = xy; 
    traj.t  = t;
    
    save('trajectory.mat', 'traj');
    assignin('base', 'wallPlot', wallPlot);
    assignin('base', 'scenario', xy);
    assignin('base', 'Hh', Hh);
    assignin('base', 'Wh', Wh);
    
    neonColor = [0 0.8 1]; % Azzurro neon
    offset = min(Hh, Wh) * 0.05; % Spessore del corridoio (distanza dai bordi)
    
    % Calcolo del passo per visualizzare i punti centrali distanziati
    step = floor(length(traj.xy) / 40); 
    if step < 1, step = 1; end
    idx = 1:step:length(traj.xy);
    
    switch lower(type)
        case 'line'
            % Bounding box arrotondato per la linea retta
            x_min = min(traj.xy(:,1)) - offset;
            x_max = max(traj.xy(:,1)) + offset;
            y_cen = traj.xy(1,2);
            idx = 1:step*2:length(traj.xy);
            pos = [x_min, y_cen - offset, x_max - x_min, 2*offset];
            rectangle(ax, 'Position', pos, 'Curvature', 1, 'EdgeColor', neonColor, 'LineWidth', 2.5);
            
        case 'circle'
            % Cerchi concentrici esterno e interno
            % Uso la R calcolata in precedenza per lo switch
            R = min(Hh, Wh) * 0.35; 
            
            % Esterno
            rectangle(ax, 'Position', [cx-(R+offset), cy-(R+offset), 2*(R+offset), 2*(R+offset)], ...
                      'Curvature', 1, 'EdgeColor', neonColor, 'LineWidth', 2.5);
            % Interno
            rectangle(ax, 'Position', [cx-(R-offset), cy-(R-offset), 2*(R-offset), 2*(R-offset)], ...
                      'Curvature', 1, 'EdgeColor', neonColor, 'LineWidth', 2.5);
                      
        case 'square'
            % Quadrati concentrici con angoli smussati per il corridoio
            side = min(Hh, Wh) * 0.6;
            s2 = side / 2;
            
            % Esterno
            pos_out = [cx-s2-offset, cy-s2-offset, side+2*offset, side+2*offset];
            rectangle(ax, 'Position', pos_out, 'Curvature', 0.15, 'EdgeColor', neonColor, 'LineWidth', 2.5);
            % Interno
            pos_in = [cx-s2+offset, cy-s2+offset, side-2*offset, side-2*offset];
            rectangle(ax, 'Position', pos_in, 'Curvature', 0.15, 'EdgeColor', neonColor, 'LineWidth', 2.5);
    end
    
    % Disegna il percorso centrale a punti (stile LED/marker luminosi)
    plot(ax, traj.xy(idx,1), traj.xy(idx,2), 'o', ...
        'MarkerSize', 5, 'MarkerEdgeColor', neonColor, ...
        'MarkerFaceColor', [0.7 0.9 1], 'LineWidth', 1.5);

    % Titolo aggiornato con il nuovo colore
    title(ax, ['Tuning Scenario: ', upper(type)], 'Color', neonColor, 'FontSize', 12, 'FontWeight', 'bold');
   
    disp(['Salvato trajectory.mat per scenario: ', type]);

end