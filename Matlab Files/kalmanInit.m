% function [R,Q,A,C,x,Sigma] = kalmanInit()
% This function initializes the parameters of the Kalman Filter using a
% constant speed motion model
%
% Inputs:
%           param         scalar, to update value of Q
%           mmodel        scalar, choose between motion model
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
function [R,Q,A,C] = kalmanInit(param, mmodel)

dt = 1; % Discrete time

% Define system parameters
% If R >> Q, then Kalman assumes our motion model is not good and puts more
% weight on them mesaurements. Else if Q >> R, then Kalman Filter assumes
% the measurements are not really trustful and Kalman puts more weight on
% the motion model.

if mmodel == 0
    R = 10*eye(4); % Process noise

    %If good circle
    if param == 1
        Q = 1*eye(2); % Measurement noise
    %Not good circle
    elseif param == 2
        Q = 10*eye(2);
    %No circle
    else
        Q = 10000000*eye(2);
    end

    A = [1,0,dt,0;
         0,1,0,dt;
         0,0,1,0;
         0,0,0,1]; % State transition matrix
    C = [1, 0, 0, 0; 
         0, 1, 0, 0]; % Measurement - State mapping

     % Note that we use B = 0, since we are using object tracking (not active 
     % agent). 
     
elseif mmodel == 1
    R = 10*eye(6); % Process noise

    %If good circle
    if param == 1
        Q = 1*eye(2); % Measurement noise
    %Not good circle
    elseif param == 2
        Q = 10*eye(2);
    %No circle
    else
        Q = 10000000*eye(2);
    end

    A = [1,0,dt,0,dt/2,0;
         0,1,0,dt,0,dt/2;
         0,0,1,0,dt/2,0;
         0,0,0,1,0,dt/2;
         0,0,0,0,1,0;
         0,0,0,0,0,1]; % State transition matrix
    C = [1, 0, 0, 0, 0, 0; 
         0, 1, 0, 0, 0, 0]; % Measurement - State mapping

     % Note that we use B = 0, since we are using object tracking (not active 
     % agent).
end