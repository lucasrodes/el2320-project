% function S_bar = weight(S_bar,Psi,outlier)
%           S_bar(t)            4XM
%           outlier             1Xn
%           Psi(t)              1XnXM
% Outputs: 
%           S_bar(t)            4XM
function S_bar = weight(S_bar,Psi,outlier)

    %BE CAREFUL TO NORMALIZE THE FINAL WEIGHTS
     %Outlier vector value is 1 if the current observation is an outlier and
    %cero if not
    Outlier_not = ~outlier; %Not outlier
    %indexes of psi values that are not discarded
    Psi_pass = Psi(1,find(Outlier_not),:);
    %We calculate the product of all the valid values of ps
    Prod = prod(Psi_pass,2);
    %BE CAREFUL TO NORMALIZE THE FINAL WEIGHTS
    %Normalization
    Prod = Prod/sum(Prod);
    %In the 4th row of the estimation the weights are saved
    S_bar(4,:)= Prod;

end