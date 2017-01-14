% function S_bar = weight(S_bar,Psi,outlier)
%           S_bar(t)            3XM
% Outputs: 
%           S_bar(t)            3XM
function S_bar = weight_Particles(S_bar, Im_in)

    alpha = 8;
    beta = 0.5;
    underflow = 1e-10;
    %M aybe roundess parameter should be added to the weight
    Kernel =(1/253)*[ 0 0 0 0 1 1 0 0 0 0; 0 0 0 1 8 8 1 0 0 0;0 0 1 8 27 27 8 1 0 0;0 1 8 27 81 81 27 8 1 0; 1 8 27 81 253 253 81 27 8 1 ;
               1 8 27 81 253 253 81 27 8 1 ; 0 1 8 27 81 81 27 8 1 0 ;0 0 1 8 27 27 8 1 0 0 ; 0 0 0 1 8 8 1 0 0 0;0 0 0 0 1 1 0 0 0 0];
     Out = conv2(single(Im_in),Kernel,'same');
%     Kernel = [ 0 0 0 0 1 1 0 0 0 0; 0 0 0 1 1 1 1 0 0 0;0 0 1 1 1 1 1 1 0 0;0 1 1 1 1 1 1 1 1 0; 1 1 1 1 1 1 1 1 1 1 ;
%                1 1 1 1 1 1 1 1 1 1 ; 0 1 1 1 1 1 1 1 1 0 ;0 0 1 1 1 1 1 1 0 0 ; 0 0 0 1 1 1 1 0 0 0;0 0 0 0 1 1 0 0 0 0];
%      Out = conv2(single(Im_in),Kernel,'same');
%     H = fspecial('Gaussian',[3 3],5);
%     Out = conv2(single(Im_in),H,'same');

    %Now we only take into account if it is white or black. White is a
    %possible good object so high weight
    for i = 1:size(S_bar,2)
        Weights(i) = Out(S_bar(1,i),S_bar(2,i)) + underflow;
    end
    
    %BE CAREFUL TO NORMALIZE THE FINAL WEIGHTS
    %Normalization
    Weights = Weights/sum(Weights);
    %In the 4th row of the estimation the weights are saved
    S_bar(3,:)= Weights;

end