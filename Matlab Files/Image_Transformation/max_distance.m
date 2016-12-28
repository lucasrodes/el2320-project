function distance = max_distance(in,centerx,centery)
    max = 0;
    dist = 0;
    for i = 1:size(in,1)
        for j = 1:size(in,2)
            if in(i,j) >= 1
                dist = norm( [i j] - [centerx centery] );
            end
            if dist >= max
                max = dist;
            end
        end
    end
    distance = max;
end