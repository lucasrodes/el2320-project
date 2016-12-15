clear all
close all

BEGINING = 45;
ENDING = 65;

particle_size = 2;
c_size = 12;
%Video input file
v = VideoReader('Bouncing_Ball_Reference.avi');

colour_thres = 1.55;
%outputVideo = VideoWriter('out.avi');
threshold_square = 15;
%open(outputVideo)

%Get image size x - vertical y - horizontal
[x,y,~] = size(readFrame(v));
% Parameter Initialization
[S,R,Q,Lambda_psi] = init_Particles(x,y);

%Specify that reading should begin 2.5 seconds from the beginning of the video.
v.CurrentTime = BEGINING;

%for the moment I want this for the output
colormap(gray(256));

while hasFrame(v) || v.currentTime <= ENDING
    %Frame matrix
    vidFrame = readFrame(v);
    
    RGB = imageTransformation( vidFrame, colour_thres)
    %%%%%%%%%%%%%%%%%%%%
    %%Particles filter%%
    %%%%%%%%%%%%%%%%%%%%
   
    %we get the particles and the outliers this way
    tic
    [S] = Particles_filters(S,R,x,y,out,particle_size);
    centroid = mean(S,2);
    for i=1:size(S,2)
       RGB(S(1,i)-round(particle_size/2)+1:S(1,i)+round(particle_size/2),S(2,i)-round(particle_size/2)+1:S(2,i)+round(particle_size/2),2) = 255;
       RGB(S(1,i)-round(particle_size/2)+1:S(1,i)+round(particle_size/2),S(2,i)-round(particle_size/2)+1:S(2,i)+round(particle_size/2),1) = 0;
       vidFrame(S(1,i)-round(particle_size/2)+1:S(1,i)+round(particle_size/2),S(2,i)-round(particle_size/2)+1:S(2,i)+round(particle_size/2),2) = 255;
       %Calculate distances to centroid
       distance(i) = sqrt((S(1,i)-centroid(1)).^2 + (S(2,i)-centroid(2)).^2);
    end
    
    
    
    %Paint the centroid
    RGB(centroid(1)-round(c_size/2)+1:centroid(1)+round(c_size/2),centroid(2)-round(c_size/2)+1:centroid(2)+round(c_size/2),3) = 255;
    RGB(centroid(1)-round(c_size/2)+1:centroid(1)+round(c_size/2),centroid(2)-round(c_size/2)+1:centroid(2)+round(c_size/2),1) = 0;
    vidFrame(centroid(1)-round(c_size/2)+1:centroid(1)+round(c_size/2),centroid(2)-round(c_size/2)+1:centroid(2)+round(c_size/2),:) = 255;
    
    distance = sort(distance);
    max_distance = distance(size(S,2) - threshold_square);
    if centroid(1) > x/2
        if max_distance > x - centroid(1)
        max_distance = round(x-centroid(1) - 1);
        end
    elseif centroid(1) <= x/2
        if max_distance > centroid(1)
        max_distance = round(centroid(1) - 1);
        end
    end
    subplot(2,1,1); image(RGB); axis image
    hold on
    rectangle('position',[centroid(2)-max_distance centroid(1)-max_distance 2*max_distance 2*max_distance], 'EdgeColor','r')
    hold off
    subplot(2,1,2); image(vidFrame); axis image
    hold on
    rectangle('position',[centroid(2)-max_distance centroid(1)-max_distance 2*max_distance 2*max_distance], 'EdgeColor','r')
    hold off
    toc
    %writeVideo(outputVideo,vidFrame)
    %%%%%%%%%%%%%%%%%%%
    %%Post operations%%
    %%%%%%%%%%%%%%%%%%%
%     
%     centroid(k,:) = round(stats(k).Centroid);
%     vidFrame((centroid(k,2)-4:centroid(k,2)+4),(centroid(k,1)-4:centroid(k,1)+4),:) = 256;
%     distance = sqrt(area/pi);
%     vidFrame = drawCircle(vidFrame,centroid(k,2),centroid(k,1),distance);
% 
%     subplot(1,2,1), image(vidFrame);
%     title('Original');
%     subplot(1,2,2),image(256*out);
%     title('Out');
%     lapse = toc;

    %We ensure the video output has the same frame rate as the original
    pause((1/v.FrameRate));
end

%close(outputVideo)