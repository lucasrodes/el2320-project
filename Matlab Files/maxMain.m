% function maxMain()
% This function combines the Particle Filter and the Kalman Filter to do
% object tracking
%
function maxMain()

% Initialize parameters of the Kalman Filter
[R,Q,A,C,x,Sigma] = kalmanInit();

while (1)
    % Kalman Filter: Prediction Step
    [mu_bar, Sigma_bar] = kalmanPredict(x, Sigma, A, R);

    % Particle Filter: Obtain measure

    % Kalman Filter: Update/Correction Step
    [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
    
    % Display estimated mean
    disp(mu);
end

end