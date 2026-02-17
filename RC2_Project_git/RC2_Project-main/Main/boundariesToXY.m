function wallsXY = boundariesToXY(B)
%   x = col - 0.5
%   y = row - 0.5

    wallsXY = [];
    for k = 1:numel(B)
        rc = B{k};  % coords for k-th objectr
        r  = rc(:,1);  % row coord
        c  = rc(:,2);  % col coord

        % pixels to cartesian coords
        x = c - 0.5;  
        y = r - 0.5;

        wallsXY = [wallsXY; [x y]; [NaN NaN]];  
    end
end