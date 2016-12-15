function S = Particles_filters(S,R,x,y,Im_in,particle_size)

%Prediction
[S_bar] = Predict_circular(S,R,x,y,particle_size);

% Particles weightening
S_bar = weight_Particles(S_bar,Im_in);

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