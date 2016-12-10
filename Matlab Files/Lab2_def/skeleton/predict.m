% function [S_bar] = predict(S,u,R)
% This function should perform the prediction step of MCL
% Inputs:
%           S(t-1)              4XM
%           v(t)                1X1
%           omega(t)            1X1
%           R                   3X3
%           delta_t             1X1
% Outputs:
%           S_bar(t)            4XM

function [S_bar] = predict(S,v,omega,R,delta_t)


% %We want to compute S_bar = S + u + N(0,R);
% %where S_bar is the estimation, S the previous state, u is the control and
% %N(0,R); is  thye diffusion (noise added to the movement of each particle)
% extract the number of particles
n = size(S,2);
%Auxiliary vector to ensure correct output dimensions
vector_n = ones(1,n);

%Circular prediction
%We already calculated the U control signal for the odometry function. 
u = [v * delta_t * cos(S(3,:)); v * delta_t * sin(S(3,:)); omega*delta_t*vector_n; zeros(1,n)]; % repeat zeros on the bottom of the matrix

% %We have to compute N(0,r). Is easy, is just a rand value multiply by the R covariance
% %It has to be a 4xM matrix. With the last row being zeros. First, a Mx3
% %random numbers matrix
Random_mat = randn(n,3) * R;

%We add a rows of zeros so the weight is not chenged, as we did for the
%matrix u
Normal_R = [Random_mat zeros(n,1)]';

%Diffusion
S_bar = S + u + Normal_R;

end