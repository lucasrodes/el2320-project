function [centroid,S, vidFrame, distance] = Particle_filter( vidFrame, RGB,out, Sp, Rp ,verbose)
  
%%%%%%%%%%%%%%%%%%%
%%Particle filter%%
%%%%%%%%%%%%%%%%%%%

%Size of the particles
particle_size = 1;

%outputVideo = VideoWriter('out.avi');

%image size
[xp,yp,~] = size(vidFrame);

%%%%%%%%%%%%%%%%%%%%%%%
%%Main code Particles%%
%%%%%%%%%%%%%%%%%%%%%%%

%Particle_filters algorithm to calculate the particles in each time
%step
%Prediction
[S_bar] = Predict_rand(Sp,Rp,xp,yp,particle_size);

% Particles weightening
S_bar = weight_Particles(S_bar,out);
[~,ind] = max(S_bar(3,:));

%Resampling
RESAMPLE_MODE = 2; 
%0=no resampling, 1=Multinomial resampling, 2=Systematic Resampling
switch RESAMPLE_MODE
    case 0
        S = S_bar;
    case 1
        S = multinomial_resample_particles(S_bar);
    case 2
        S = systematic_resample_particles(S_bar);
end

%Centroid calculation
centroid = KDE(S,[xp yp]);
    
end
    
