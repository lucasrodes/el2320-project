function [count, mu, Sigma] = KalmanAlgorithm(count, mu, Sigma, z, ...
                                               A, R, C, Q, mmodel)
    z = z';
    % (1) If we are at t = 0, we obtain the centroid and set it as 
    % the initial point. We use a variable count to know at which 
    % time step are we currently.
    if count == 0
        mu = [z; 0; 0];
        if mmodel == 1
            mu = [mu; 0; 0];
        end
        count = count+1;
    % (2) When we are at t=1, we are able to obtain the initial
    % speed as the difference of the position at t=1 and t=0.
    % Next, we also initialize the initial covariance matrix
    % with an arbitrary value (high, since we are at the
    % beginning and we are not really sure!)
    elseif  count == 1
        v = z - mu(1:2); % speed at t=1
        mu = [z; v]; % % Initial state at t=1
        if mmodel == 0     
            Sigma = 10*eye(4); % Uncertainty at the beginning
            % Prediction step
            [mu_bar, Sigma_bar] = kalmanPredict(mu, Sigma, A, R);
            % Update step
            [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
            count = count+2;
        else
            mu = [mu; 0; 0]; % position at t=1
            count = count+1;
        end
    % (3) Similar as in (2), we now are able to obtain the initial
    % acceleration as the difference of the speed at t=1 and t=0. We also
    % initialize the initial covariance matrix, which is now 6X6, with
    % hight determinant, since is the beginning and we are not really sure
    % about the state.
    elseif  count == 2
        
        x2 = centroid; % position at t=2
        vv2 = x2 - x1; % speed at t=2
        aa = vv2 - vv1; % initial acceleration
        x = [x2(1); x2(2); vv2(1); vv2(2); aa(1) ; aa(2)]; % Initial state
        Sigma = 10*eye(6); % Uncertainty at the beginning
        % Prediction step
        [mu_bar, Sigma_bar] = kalmanPredict(x, Sigma, A, R);
        z = x2; % obtain measure (should be from PF)
        % Update step
        [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
        count = count+1;
    % (4) We enter this whenever t>2.
    else
        % Prediction step
        [mu_bar, Sigma_bar] = kalmanPredict(mu, Sigma, A, R);

        % Update step
        [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
        count = count+1; 
    end
end