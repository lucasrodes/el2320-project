% function [S,R,Q,Lambda_psi] = init(bound,start_pose)
% This function initializes the parameters of the filter.
% Outputs:
%			S(0):			3XM
%			R:				3X3
%			Q:				2X2
%           Lambda_psi:     1X1
%           start_pose:     3X1
function [S,R,Q,Lambda_psi] = init_Particles(x,y)

%Particles number
M = 1000;

%Random particles generation
S = [round(rand(1,M)*(x));round(rand(1,M)*(y));(1/M)*ones(1,M)];

% Below here you may want to experiment with the values but these seem to work for most datasets.
%Variances
R = 3000*diag([1e-2 1e-2]); %process noise covariance matrix
Q = 10*diag([1e-1;1e-1]); % measurement noise covariance matrix
%Outlier threshold
Lambda_psi = 0.0001;

end
