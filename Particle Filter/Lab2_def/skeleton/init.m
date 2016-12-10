% function [S,R,Q,Lambda_psi] = init(bound,start_pose)
% This function initializes the parameters of the filter.
% Outputs:
%			S(0):			4XM
%			R:				3X3
%			Q:				2X2
%           Lambda_psi:     1X1
%           start_pose:     3X1
function [S,R,Q,Lambda_psi] = init(bound,start_pose)
%Particles number
M = 1000;
%Particle boundaries
part_bound = 20;
%Known pose?
if ~isempty(start_pose)
    S = [repmat(start_pose,3,M); 1/M*ones(1,M)];
else
    S = [rand(1,M)*(bound(2) - bound(1)+2*part_bound) + bound(1)-part_bound;
         rand(1,M)*(bound(4) - bound(3)+2*part_bound) + bound(3)-part_bound;
         rand(1,M)*2*pi-pi;
         1/M*ones(1,M)];
end
% Below here you may want to experiment with the values but these seem to work for most datasets.
%Variances
R = 10*diag([1e-2 1e-2 1e-2]); %process noise covariance matrix
Q = 10*diag([1e-1;1e-1]); % measurement noise covariance matrix
%Outlier threshold
Lambda_psi = 0.0001;

end
