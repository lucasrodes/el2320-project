clear all;
close all;
addpath(genpath('Image_Transformation'));
addpath(genpath('Kalman'));
addpath(genpath('Particles'));

%set to one if some areas want to be erased to check how god does the
%kalman filter works
OBSTACLES = 1;

%Video input file
v = VideoReader('Videos/NES_Longplay_[456_Pinball.mov');

%Specify that reading should begin 2.5 seconds from the beginning of the video.
v.CurrentTime = 255;

%Parameter to decide the colour filtering
colour_thres = 1.55;

%Flag to differenciate the first iteration from the following
count = 0;

%We need this to identify a certain color
c_thres = 12;
    
%%%%%%%%%%%%%%%%%%%
%%Particle filter%%
%%%%%%%%%%%%%%%%%%%

%Size of the particles
particle_size = 1;

%Size of the centroid
c_size = 4;

%outputVideo = VideoWriter('out.avi');
threshold_square = 30;

%Get image size x - vertical y - horizontal
[xp,yp,~] = size(readFrame(v));
% Parameter Initialization
[Sp,Rp,Lambda_psi] = init_Particles(xp,yp);

while hasFrame(v) || v.currentTime <= ENDING
  
    tic
    %Frame matrix
    vidFrame = readFrame(v); 
    
    if OBSTACLES
        vidFrame = Video_editing(vidFrame);
    end
    %Filters the image and transforms it in a binary image. White will
    %represent high intensity colours and black the background. The put put
    %format is RGB so we can represent colorful particles
    [RGB, out] = imageTransformation(vidFrame,colour_thres,[187,187,187],c_thres);
   
    %Particle_filters algorithm to calculate the particles in each time
    %step
    [Sp] = Particles_filters(Sp,Rp,xp,yp,out,particle_size);
    
    %Centroid calculation
    centroid_aux = mean(Sp,2);
    centroid = centroid_aux(1:2);
    
    %This function represents the particles in the binary and original
    %pictures and compute the distances of each particle to the centroid in
    %ascending order
    [vidFrame, RGB, distance] = particle_distance_and_out( vidFrame ,RGB, Sp,centroid,particle_size,c_size );
   
    vidFrame(abs(round(centroid(1))-4 + 1):round(centroid(1))+4,abs(round(centroid(2))-4 +1):round(centroid(2))+4,3) = 255;
    vidFrame(abs(round(centroid(1))-4 + 1):round(centroid(1))+4,abs(round(centroid(2))-4 +1):round(centroid(2))+4,1:2) = 0;
    RGB(abs(round(centroid(1))-4 + 1):round(centroid(1))+4,abs(round(centroid(2))-4 +1):round(centroid(2))+4,1:2) = 0;
    RGB(abs(round(centroid(1))-4 + 1):round(centroid(1))+4,abs(round(centroid(2))-4 +1):round(centroid(2))+4,3) = 255;
   
    [max_distance_x, max_distance_y] = rect_size(xp,yp,centroid(1),centroid(2),threshold_square,distance,Sp);
    %writeVideo(outputVideo,vidFrame)
    
%     image(vidFrame); axis image;
    
    %For other outputs
    subplot(2,1,1); image(RGB); axis image
    hold on
    rectangle('position',[centroid(2)-max_distance_y centroid(1)-max_distance_x 2*max_distance_y 2*max_distance_x], 'EdgeColor','r')
    hold off
    subplot(2,1,2); image(vidFrame); axis image
    hold on
    rectangle('position',[centroid(2)-max_distance_y centroid(1)-max_distance_x 2*max_distance_y 2*max_distance_x], 'EdgeColor','r')
    hold off

    %We ensure the video output has the same frame rate as the original
    pause(abs((1/v.FrameRate)-toc));
end

%close(outputVideo)