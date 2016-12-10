% function h = observation_model(S,W,j)
% This function is the implementation of the observation model
% The bearing should lie in the interval [-pi,pi)
% Inputs:
%           S           4XM
%           W           2XN
%           j           1X1
% Outputs:  
%           h           2XM
function h = observation_model(S,W,j)

%is similar to the code developed for lab 1, but instead a 2x1 vector, now
%is a 2xM
%     h1=norm(M(:,j)-x(1:2));
%     h2=atan2((M(2,j)-x(2)),M(1,j)-x(1))-x(3);
%     h2=mod(h2+pi,2*pi)-pi;
%     h=[h1;h2];

%Lets get importan sizes

M = size(S,2);
%We want to do W(:,j) - S(1:2,:). The out put has to be the size of S, then
%we have to modify W(:,j) as it is 2x1
W_mod = repmat(W(:,j),1,M); %Now it is 2XM

for i=1:M
    h(1,i)= norm(W_mod(:,i) - S(1:2,i));
    h(2,i)= atan2(W_mod(2,i)-S(2,i),W_mod(1,i)-S(1,i)) -S(3,i);
end
%We change it to the needed interval
h(2,:)=mod(h(2,:)+pi,2*pi)-pi;

end