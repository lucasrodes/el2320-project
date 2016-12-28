% function S_bar = weight(S_bar,Psi,outlier)
%           S_bar(t)            3XM
% Outputs: 
%           S_bar(t)            3XM
function S_bar = weight_Particles(S_bar, Im_in)
    
    %Maybe roundess parameter should be added to the weight
    
    %Now we only take into account if it is white or black. White is a
    %possible good object so high weight
    for i = 1:size(S_bar,2)
        Weights(i) = Im_in(S_bar(1,i),S_bar(2,i))*10000 + 1;
    end
    
    %BE CAREFUL TO NORMALIZE THE FINAL WEIGHTS
    %Normalization
    Weights = Weights/sum(Weights);
    %In the 4th row of the estimation the weights are saved
    S_bar(3,:)= Weights;

end