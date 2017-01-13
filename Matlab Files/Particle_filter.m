function [centroid,S, vidFrame, distance] = Particle_filter( vidFrame, RGB,out, Sp, Rp ,verbose)
  
%%%%%%%%%%%%%%%%%%%
%%Particle filter%%
%%%%%%%%%%%%%%%%%%%

%Size of the particles
particle_size = 1;

%Size of the centroid
c_size = 4;

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
centroid_aux = mean(S,2);
centroid = centroid_aux(1:2);

%This function represents the particles in the binary and original
%pictures and compute the distances of each particle to the centroid in
%ascending order
[vidFrame, RGB, distance] = particle_distance_and_out( vidFrame ,RGB, S,centroid,particle_size,c_size );

vidFrame(abs(round(centroid(1))-4 + 1):round(centroid(1))+4,abs(round(centroid(2))-4 +1):round(centroid(2))+4,3) = 255;
vidFrame(abs(round(centroid(1))-4 + 1):round(centroid(1))+4,abs(round(centroid(2))-4 +1):round(centroid(2))+4,1:2) = 0;
RGB(abs(round(centroid(1))-4 + 1):round(centroid(1))+4,abs(round(centroid(2))-4 +1):round(centroid(2))+4,1:2) = 0;
RGB(abs(round(centroid(1))-4 + 1):round(centroid(1))+4,abs(round(centroid(2))-4 +1):round(centroid(2))+4,3) = 255;
    
end
    
