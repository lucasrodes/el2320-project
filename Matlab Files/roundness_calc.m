function [roundness, parameter] = roundness_calc(Sp, threshold_square)
    %We compute the roundness of the ball to choose the Q used.
    round_part = Sp(1:2,1:(size(Sp,2) - threshold_square));
    [L,area] = boundary(round_part',0);
    boundaries = Sp(1:2,L);
    % compute a simple estimate of the object's perimeter
    delta_sq = diff(boundaries').^2;
    perimeter = sum(sqrt(sum(delta_sq,2)));

    % obtain the area calculation corresponding to label 'k'
    % compute the roundness metric
    roundness = 4*pi*area/perimeter^2;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%>0.95 is a godd enought circle                              %%
    %%aproximately, 0.75-0.6 means that there was nothing detected%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Parameters
    if roundness >= 0.90
        %Good circle, then  
        parameter = 1;
    elseif roundness < 0.90 && roundness >= 0.8
        %Not very good, higher Q
        parameter = 2;
    elseif roundness < 0.8
        %No circle
        parameter = 3;
    else
        parameter = 3;
    end
end