% function S = multinomial_resample(S_bar)
% This function performs systematic re-sampling
% Inputs:   
%           S_bar(t):       4XM
% Outputs:
%           S(t):           4XM
function S = multinomial_resample(S_bar)
%Importal sizes
M = size(S_bar,2);
S = zeros(4,M);
for m = 1: M
    CDF(m) = sum(S_bar(4,1:m));
end
%This part will distribute the less heavy particles arround the heavier
%ones
for m = 1: M
    rm = rand(); % random number in the interval 0,1
    %We finde the frist value that is biiger than the random number
    i = find( CDF >= rm , 1);
    S(:,m) = S_bar(:,i);
    %We have to reinitialize the values of the weights for the next step
    S(4,:) = 1/M;
end
end
