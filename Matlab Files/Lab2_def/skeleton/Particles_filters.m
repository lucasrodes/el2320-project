function S = Particles_filters(S,R,x,y)

%Prediction
[S_bar] = Predict_circular(S,R,x,y);
% 
% Particles weightening
S_bar = weight_Particles(S_bar,Im_in);

% %Resampling
% RESAMPLE_MODE = 2; 
% %0=no resampling, 1=Multinomial resampling, 2=Systematic Resampling
% switch RESAMPLE_MODE
%     case 0
%         S = S_bar;
%     case 1
%         S = multinomial_resample(S_bar);
%     case 2
%         S = systematic_resample(S_bar);
% end