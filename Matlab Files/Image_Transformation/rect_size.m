function [max_distance_x, max_distance_y] = rect_size(xp,yp,centroidx,centroidy, threshold_square,distance,Sp)
    %Function that computes the maximum possible size of the rectangle that
    %envolves the estimate with the input conditions given
    if nargin < 7
        max_distance_x = distance;
        max_distance_y = distance;
    else
    max_distance_x = distance(size(Sp,2) - threshold_square);
    max_distance_y = distance(size(Sp,2) - threshold_square);
    end
    
    if centroidx > xp/2
        if max_distance_x > xp - centroidx
            max_distance_x = round(xp-centroidx - 1);
        end
    elseif centroidx <= xp/2
        if max_distance_x > centroidx
            max_distance_x = round(centroidx - 1);
        end
    end
    if centroidy > yp/2
        if max_distance_y > yp - centroidy
            max_distance_y = round(yp-centroidy - 1);
        end
    elseif centroidy <= yp/2
        if max_distance_y > centroidy
            max_distance_y = round(centroidy - 1);
        end
    end
end