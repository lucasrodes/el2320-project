% function [outlier,Psi] = associate_known(S_bar,z,W,Lambda_psi,Q,known_associations)
%           S_bar(t)            4XM
%           z(t)                2Xn
%           W                   2XN
%           Lambda_psi          1X1
%           Q                   2X2
%           known_associations  1Xn
% Outputs: 
%           outlier             1Xn
%           Psi(t)              1XnXM
function [outlier,Psi] = associate_known(S_bar,z,W,Lambda_psi,Q,known_associations)
%Lets get usefull vector sizes
N = size(W,2);
n = size(z,2);
M = size(S_bar,2);

%Algorithm from the lecture notes. 
for i = 1:n
    for m = 1:M
        for k = 1:N
            %as it is said in the lab notes
            zHat(:,:,k) = observation_model(S_bar,W,k); %Dim 2xMxN
            nu(:,m,k) = z(:,i) - zHat(:,m,k); % nu 2xMxN
            nu(2,m,k)=mod(nu(2,m,k)+pi,2*pi)-pi;%as it was specified
            fi(i,m,k) = (1/(2*pi*det(Q)^(1/2))*exp(-(1/2)*(nu(:,m,k)'/Q)*nu(:,m,k)));
        end
        %Associations are known so 
        Psi(i,m,:) = fi(i,m,known_associations(i));
    end
    % as in the 3.5 of the lab notes
    %as many outliers as observations made
    outlier(i)= mean(Psi(i,:)) <= Lambda_psi;
end
%we need to reshape, as Psi is now nxMx1 and we need it as 1xnxM
Psi=reshape(Psi,[1 n M]);
end

