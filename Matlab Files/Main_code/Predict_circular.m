% function [S_bar] = predict(S,u,R)
% This function should perform the prediction step of MCL
% Inputs:
%           S(t-1)              3XM
%           R                   2x2
%          
% Outputs:
%           S_bar(t)            4XM

function [S_bar] = Predict_circular(S,R,x,y)

%Number of particles
N = size(S, 2);

%The prediction of the particles has ti be random in this case as we can
%not measure any odometry or movement of the object tracked
Mult_factor = 0.01;

dimensions = zeros(2,N);
dimensions(1,1:N) = x;
dimensions(2,1:N) = y;
S(1:2,:) = abs(S(1:2,:) + Mult_factor*dimensions.*randn(2,N));

% %We have to compute N(0,r). Is easy, is just a rand value multiply by the R covariance
% %It has to be a 4xM matrix. With the last row being zeros. First, a Mx3
% %random numbers matrix
Random_mat = randn(N,2) * R;

%We add a rows of zeros so the weight is not chenged, as we did for the
%matrix u
Normal_R = [Random_mat zeros(N,1)]';

%Diffusion
S = (round(S + Normal_R));

%Check dimension boundaries
S(1,:) = S(1,:).*(S(1,:) < x);
S(2,:) = S(2,:).*(S(2,:) < y);
S(1:2,:) = S(1:2,:) + (S(1:2,:) == 0);
S_bar = abs(S);

end