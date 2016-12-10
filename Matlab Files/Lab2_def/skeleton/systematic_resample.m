
% function S = systematic_resample(S_bar)
% This function performs systematic re-sampling
% Inputs:   
%           S_bar(t):       4XM
% Outputs:
%           S(t):           4XM
%We use the same structure as in the multinomial

function S = systematic_resample(S_bar)
%Importal sizes
M = size(S_bar,2);
S = zeros(4,M);
for m = 1: M
    CDF(m) = sum(S_bar(4,1:m));
end
%The random number is outside the loop now
rm = rand()/M; % random number in the interval 0,1/M
%This part will distribute the less heavy particles arround the heavier
%ones
for m = 1: M
   
    %We finde the frist value that is biiger than the random number
    i = find( CDF >= rm + (m-1)/M , 1);
    S(:,m) = S_bar(:,i);
    %We have to reinitialize the values of the weights for the next step
    S(4,:) = 1/M;
end
end
