clear all;
close all;
%Video input file
v = VideoReader('Bouncing_Ball_Reference.avi');

%Specify that reading should begin 2.5 seconds from the beginning of the video.
v.CurrentTime = 40;

%Create an axes. Then, read video frames until no more frames are available to read.
currAxesGrey = axes;
currAxesOri = axes;

colormap(gray(256)) 

while hasFrame(v)
    %Frame matrix
    vidFrame = readFrame(v);
    %To gray
    grey = rgb2gray(vidFrame);
    
    sobel = edge(grey,'sobel',0.02);
    canny = edge(grey,'canny',0.02);
    subplot(2,2,1), image(vidFrame);
    title('Original');
    subplot(2,2,2),image(256*sobel);
    title('Grey');
    subplot(2,2,3), image(256*canny);
    title('Binary');
    %We ensure the video output has the same frame rate as the original
    pause(1/v.FrameRate);
end