% function S_bar = weight(S_bar,Psi,outlier)
%           S_bar(t)            3XM
% Outputs: 
%           S_bar(t)            3XM
function S_bar = weight_Particles(S_bar, Im_in)
    %Variable to ensure that any particle have a 0 probability
    underflow = 1e-3;
    
    %We need to compute a Kernel around the binary image sin order to give
    %the importance weights to the particles. This kernel is circular as
    %the target objective is circular too
    Kernel = KernelFunction(1);
    Out = conv2(single(Im_in),Kernel,'same');

    %The weight will be the value of the convolved image in the position of
    %each particle plus a small underflow to make sure that any particle
    %has a zero probability
    for i = 1:size(S_bar,2)
        Weights(i) = Out(S_bar(1,i),S_bar(2,i)) + underflow;
    end
    
    %BE CAREFUL TO NORMALIZE THE FINAL WEIGHTS
    %Normalization
    Weights = Weights/sum(Weights);
    
    %In the 3th row of the estimation the weights are saved
    S_bar(3,:)= Weights;

end