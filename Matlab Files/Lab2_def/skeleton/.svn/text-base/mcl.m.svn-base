% function [S,outliers] = mcl(S,R,Q,z,known_associations,u,M,Lambda_psi,Map_IDS,delta_t,t)
% This function should perform one iteration of Monte Carlo Localization
% Inputs:
%           S(t-1)              4XM
%           R                   3X3
%           Q                   2X2
%           z                   2Xn
%           known_associations  1Xn
%           u                   3X1
%           W                   2XN
%           t                   1X1
%           delta_t             1X1
%           Lambda_psi          1X1
%           Map_IDS             1XN
% Outputs:
%           S(t)                4XM
%           outliers            1X1
function [S,outliers] = mcl(S,R,Q,z,known_associations,v,omega,W,Lambda_psi,Map_IDS,delta_t,t)
[S_bar] = predict(S,v,omega,R,delta_t);
USE_KNOWN_ASSOCIATIONS = 0;

if USE_KNOWN_ASSOCIATIONS
    map_ids = zeros(1,size(z,2));
    for i = 1 : size(z,2)
        map_ids(i) = find(Map_IDS == known_associations(i));
    end
    [outlier,Psi] = associate_known(S_bar,z,W,Lambda_psi,Q,map_ids);
else
    [outlier,Psi] = associate(S_bar,z,W,Lambda_psi,Q);
end
outliers = sum(outlier);
if outliers
    display(sprintf('warning, %d measurements were labeled as outliers, t=%d',sum(outlier), t));
end
S_bar = weight(S_bar,Psi,outlier);

RESAMPLE_MODE = 2; 
%0=no resampling, 1=Multinomial resampling, 2=Systematic Resampling
switch RESAMPLE_MODE
    case 0
        S = S_bar;
    case 1
        S = multinomial_resample(S_bar);
    case 2
        S = systematic_resample(S_bar);
end
end
