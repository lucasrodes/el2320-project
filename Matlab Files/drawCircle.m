function image = drawCircle( in, xm, ym, distance, thickness )
    if nargin < 5
        thickness = 1;
    end
    image = in;
    if distance > 0
        for x = xm - distance:xm + distance
                if x > 1
                    y1 = sqrt(distance*distance - (x - xm)*(x- xm)) + ym;
                    y2 = -sqrt(distance*distance - (x - xm)*(x- xm)) + ym;
                    a=y1
                    b=y2
                    c=x
                    if round(y1) > 2 && round(x) > 2 
                        image((round(x)-2*thickness:round(x)+2*thickness),(round(y1)-2*thickness:round(y1)+2*thickness),:) = 256; 
                    end
                    if round(y2) > 2 && round(x) > 2 
                        image((round(x)-2*thickness:round(x)+2*thickness),(round(y2)-2*thickness:round(y2)+2*thickness),:) = 256;
                    end
                end
        end
    end
