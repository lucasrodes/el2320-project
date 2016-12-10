
% function [v,omega] = calculate_odometry(e_R,e_L,E_T,B,R_R,R_L,delta_t)
% This function should calculate the odometry information
% Inputs:
%           e_L(t):         1X1
%           e_R(t):         1X1
%           E_T:            1X1
%           B:              1X1
%           R_L:            1X1
%           R_R:            1X1
%           delta_t:        1X1
% Outputs:
%           v(t):           1X1
%           omega(t):       1X1
function [vt,omega] = calculate_odometry(e_R,e_L,E_T,B,R_R,R_L,delta_t)
%This code was reused from the lab 1 code, few modifications.
if ~delta_t
    vt = 0;
    omega = 0;
    return;
end
    wR = (2*pi*e_R)/(E_T*delta_t);
    wL = (2*pi*e_L)/(E_T*delta_t);
    omega = (wR*R_R - wL*R_L)/B;
    vt = (wR*R_R + wL*R_L)/2;
end