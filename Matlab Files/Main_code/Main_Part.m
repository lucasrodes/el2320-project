clear all
close all

BEGINING = 50;
ENDING = 65;

%Video input file
v = VideoReader('Bouncing_Ball_Reference.avi');

%outputVideo = VideoWriter('out.avi');

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
     
% Parameter Initialization
     
    %Get rgb values
    r = vidFrame(:, :, 1);
    g = vidFrame(:, :, 2);
    b = vidFrame(:, :, 3);
    thres = 1.55;
    %Thresholds
    justGreen = g - r/thres - b/thres;
    justRed = r - g/thres - b/thres;
    justBlue = b - r/thres - g/thres;
    %To gray
    green = justGreen > 40;
    red = justRed > 40;
    blue = justBlue > 40;
    %Binary pic
    out = green + red + blue;
    %%%%%%%%%%%%%%%%%%%%
    %%Particles filter%%
    %%%%%%%%%%%%%%%%%%%%
   
    %we get the particles and the outliers this way
    [S] = Particles_filters(S,R,x,y,out);
    vidFrame(S(1,:),S(2,:),1) = 255;
    subplot(1,1,1); image(vidFrame)
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