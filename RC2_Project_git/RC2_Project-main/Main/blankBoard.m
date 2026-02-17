function G = blankBoard()
    % Una griglia 20x20 vuota con bordi (muri)
    G = ones(20, 20);
    G(1,:) = 0; G(end,:) = 0;
    G(:,1) = 0; G(:,end) = 0;
end

