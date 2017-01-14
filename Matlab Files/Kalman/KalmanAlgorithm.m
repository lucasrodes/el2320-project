% function [mu, Sigma] = KalmanAlgorithm(vidFrame, count, mu, Sigma, z, ...
%                                       A, R, C, Q, mmodel)
% This function performs the Kalman Filter algorithm.
%
% Inputs:
%           vidFrame
%           count             1X1
%           mu(t-1)           nX1
%           Sigma(t-1)        nXn
%           z                 mX1
%           A                 nXn
%           R                 nXn
%           C                 mXn
%           Q                 mXm
% Outputs:   
%           mu(t)             nX1
%           Sigma(t)          nXn
%
function [mu, Sigma] = KalmanAlgorithm(vidFrame, count, mu, Sigma, z, ...
                                       A, R, C, Q, mmodel)
    
    % We use a variable count to know at which 
    % time step are we currently.
    z = z';

    switch mmodel
        
        % CONSTANT VELOCITY MODEL
        case 0
            
            switch count 
                % (1) If we are at t = 0, we obtain the measure and set it 
                % as the initial position coordinates. 
                case 0
                    mu = [z; 0; 0];
                
                % (2) When we are at t=1, we are able to obtain the initial
                % speed as the difference of the position at t=1 and t=0.
                % Next, we also initialize the initial covariance matrix
                % with an arbitrary value (high, since we are at the
                % beginning and we are not really sure!)  
                case 1
                    v = z - mu(1:2); % speed at t=1
                    mu = [z; v]; % % Initial state at t=1
                    Sigma = 10*eye(4); % Uncertainty at the beginning
                    % Prediction step
                    [mu_bar, Sigma_bar] = kalmanPredict(mu, Sigma, A, R);
                    % Update step
                    [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);

                % (3) Regular prediction and Update step.
                otherwise
                    % Prediction step
                    [mu_bar, Sigma_bar] = kalmanPredict(mu, Sigma, A, R);
                    % Update step
                    [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
            end
        
        % CONSTANT ACCELERATION MODEL
        otherwise
            switch count 
                % (1) If we are at t = 0, we obtain the measure and set it 
                % as the initial position coordinates. 
                case 0
                    mu = [z; 0; 0; 0; 0];
                
                % (2) When we are at t=1, we are able to obtain the initial
                % speed as the difference of the position at t=1 and t=0.
                
                case 1
                    v = z - mu(1:2); % speed at t=1
                    mu = [z; v; 0; 0]; % % Initial state at t=1
                
                % (3) At t=2, we can obtain an estimation of the initial 
                % acceleration by taking the difference of the velocity at
                % t = 1, t = 0. Next, we also initialize the initial 
                % covariance matrix with an arbitrary value (high, since 
                % we are at the beginning and we are not really sure!)  
                case 2
                    v = z - mu(1:2);
                    a = v - mu(3:4);
                    mu = [z; v; a];
                    Sigma = 10*eye(6); % Uncertainty at the beginning
                    % Prediction step
                    [mu_bar, Sigma_bar] = kalmanPredict(mu, Sigma, A, R);
                    % Update step
                    [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
                    
                % (3) Regular prediction and Update step.
                otherwise
                    % Prediction step
                    [mu_bar, Sigma_bar] = kalmanPredict(mu, Sigma, A, R);
                    % Update step
                    [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
            end
            
    end
    
    % Adjust position so that we are able to nicely plot it
    [xp,yp,~] = size(vidFrame);
    if mu(1) >= xp - 4
        mu(1) = xp - 4;
    end
    if mu(2) >= yp - 4
         mu(2) = yp - 4;
    end
end