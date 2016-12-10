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
    %Binary pic
    normalizedThresholdValue = 0.6; % In range 0 to 1.
    thresholdValue = normalizedThresholdValue * max(max(grey)); % Gray Levels.
    binary = im2bw(grey, normalizedThresholdValue);       % One way to threshold to binary

%     thresholdValue = 100;
%           nary = grey > thresholdValue; % Bright objects will be chosen if you use >.
    % remove all object containing fewer than 30 pixels
    binary = bwareaopen(binary,30);
    % fill a gap in the pen's cap
    se = strel('disk',2);
    binary = imclose(binary,se);

    binary = imfill(binary,'holes');

    binary = imfill(binary, 'holes');
    binary = 256*binary;
    subplot(2,2,1), image(vidFrame);
    title('Original');
    subplot(2,2,2),image(grey);
    title('Grey');
    subplot(2,2,3), image(binary);
    title('Binary');
    %We ensure the video output has the same frame rate as the original
    pause(1/v.FrameRate);
end