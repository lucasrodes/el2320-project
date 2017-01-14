% function [S,R,Q,Lambda_psi] = init(bound,start_pose)
% This function initializes the parameters of the filter.
% Outputs:
%			S(0):			3XM
%			R:				3X3
%			Q:				2X2
%           Lambda_psi:     1X1
%           start_pose:     3X1
function [S,R,Lambda_psi] = init_Particles(x,y)

%Particles number
M = 750;

%Random particles generation
S = [round(rand(1,M)*(x));round(rand(1,M)*(y));(1/M)*ones(1,M)];

%Process variance
R = 890*diag([1e-2 1e-2]); %process noise covariance matrix


end
