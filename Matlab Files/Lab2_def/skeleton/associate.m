% function [outlier,Psi] = associate(S_bar,z,W,Lambda_psi,Q)
%           S_bar(t)            4XM
%           z(t)                2Xn
%           W                   2XN
%           Lambda_psi          1X1
%           Q                   2X2
% Outputs: 
%           outlier             1Xn
%           Psi(t)              1XnXM
function [outlier,Psi] = associate(S_bar,z,W,Lambda_psi,Q)
    %Important sizes
    M=size(S_bar,2);    %particles
    N=size(W,2);        %landmarks
    n=size(z,2);        %observations
    %As we did in the previous lab, we take this part out of the loop to do less computations   
    for j=1:N
        zHat(:,:,j) = observation_model(S_bar,W,j);
    end
    
    %It was imposible to run the code with the algorithm proposed in the
    %lab notes as it ran to slowly. 
    %Instead, we are using the diagonals of the Q matrix to save a lot of
    %time as we would need just one loop instead of three
    %we get the diagonal
    Q_dia = diag(Q);
    %to multiply the vector nu, we need that Q_diag has 1xMxN, we resize
    %then
    Q_resize = repmat(Q_dia,[1 M N]);
    %Save space for Psi
    Psi = zeros(n,M);
    for i=1:n
        %We du z - z_hat. We have to resize in order to be able to do the
        %substraction
        nu(:,:,:)= repmat(z(:,i),1,M,N)-zHat;
        %We do the change required in the lab notes
        nu(2,:,:)= mod(nu(2,:,:)+pi,2*pi) - pi;
        %We do the sumatory along the first dimension as the dimension of
        %nu.^2./Q_resize is 2xMxN and we need 1xMxN        
        fi(:,:) = prod(2*pi*Q_dia).^(-1/2)*exp(-1/2*sum(nu.^2./Q_resize,1));
        %We save only the max value of all the landmarks
        %We substitute like this the following part of the original
        %algorithm
        Psi(i,:) = max(fi,[],2); 
    end
    %We compute the outliers
    %First we give Psi the required output format
    Psi = reshape(Psi,[1 n M]);
    %Save a vector with the outliers
    outlier = mean(Psi,3)<=Lambda_psi;
    
    
end