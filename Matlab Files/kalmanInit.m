% function [R,Q,A,C,x,Sigma] = kalmanInit()
% This function initializes the parameters of the Kalman Filter
%
% Outputs:   
%           R             nXn
%           Q             mXm
%           A             nXn
%           C             mXn
%           x             nX1
%           Sigma         nXn
%
% Where n := length of state vector and m := length of measurement vector
%
function [R,Q,A,C,x,Sigma] = kalmanInit()

% Define system parameters
R = 1; % Process noise
Q = 1; % Measurement noise
A = 1; % State transition matrix
C = 1; % Measurement - State mapping

% Initialization
x = [0,0,0,0,0,0]; % Initial state vector
Sigma = sigma*eye(6); % Estimated accuracy of x

end