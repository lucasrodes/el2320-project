% function [mu_bar, Sigma_bar] = kalmanPredict(mu, A, B, u, R)
% This function performs the prediction script using Kalman Filter.
% Inputs:
%           mu(t-1)           nX1   
%           sigma(t-1)        nXn
%           A                 nXn
%           R                 nXn
% Outputs:   
%           mu_bar(t)         nX1
%           Sigma_bar(t)      nXn
function [mu_bar, Sigma_bar] = kalmanPredict(mu, Sigma, A, R)

    mu_bar = A*mu; % Predicted mean for simpler model
    Sigma_bar = A*Sigma*A' + R; % Predicted covariance
    
end