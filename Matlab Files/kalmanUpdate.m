% function [mu_bar, Sigma_bar] = kalmanPredict(A, B, mu, u, R)
% This function performs the prediction script using Kalman Filter.
% Inputs:
%           mu_bar            nX1
%           Sigma_bar         nXn
%           z                 mX1
%           C                 mXn
%           Q                 mXm
% Outputs:   
%           mu(t)         nX1
%           Sigma(t)      nXn
function [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q)
    
    v = z - C*mu_bar; % measurement innovation
    S = C*Sigma_bar*C'+Q; % innovation covariance
    K = Sigma_bar*C'/S; % Kalman gain
    mu = mu_bar + K*v; % Updated/corrected mean
    Sigma = Sigma_bar - K*C*Sigma_bar; % Updated/corrected variance
    
end