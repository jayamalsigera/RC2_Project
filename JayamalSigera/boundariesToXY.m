function wallsXY = boundariesToXY(B)
%   x = col - 0.5
%   y = row - 0.5

    wallsXY = [];
    for k = 1:numel(B)
        rc = B{k};
        r  = rc(:,1);
        c  = rc(:,2);

        x = c - 0.5;
        y = r - 0.5;

        wallsXY = [wallsXY; [x y]; [NaN NaN]];
    end
end