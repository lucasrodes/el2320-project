clear all;
close all;
%Video input file
v = VideoReader('Bouncing_Ball_Reference.avi');

%Specify that reading should begin 2.5 seconds from the beginning of the video.
v.CurrentTime = 45;

colormap(gray(256));

while hasFrame(v)
    %Frame matrix
    vidFrame = readFrame(v);
    tic
    
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
    thres2 = 3;
    out = green + red + blue;
%     out2 = bwareaopen(out,thres2*40); % get rid of small unwanted pixels 
%     out3 = imclearborder(out2); % clear pixels of the borders
%     out4 = bwareaopen(out3,thres2*60); % get rid of small unwanted pixels
%     out5 = imfill(out4,'holes'); % fill the gap on the ball top part
%     out6 = imclearborder(out5); % get rid of small unwanted pixels
     [B,L] = bwboundaries(out,'noholes');
    %Check roundness
    stats = regionprops(L,'Area','Centroid');

    threshold = 0;
    thres_are = 300;

    % loop over the boundaries
    for k = 1:length(B)

      % obtain (X,Y) boundary coordinates corresponding to label 'k'
      boundary = B{k};

      % compute a simple estimate of the object's perimeter
      delta_sq = diff(boundary).^2;
      perimeter = sum(sqrt(sum(delta_sq,2)));

      % obtain the area calculation corresponding to label 'k'
      area = stats(k).Area;
      %For the project, erase the threshold
      if area > thres_are
          % compute the roundness metric
          metric = 4*pi*area/perimeter^2;

          % display the results
          metric_string = sprintf('%2.2f',metric);

          % mark objects above the threshold with a black circle
          if metric > threshold
            centroid(k,:) = round(stats(k).Centroid);
            vidFrame((centroid(k,2)-4:centroid(k,2)+4),(centroid(k,1)-4:centroid(k,1)+4),:) = 256;
            distance = sqrt(area/pi);
            vidFrame = drawCircle(vidFrame,centroid(k,2),centroid(k,1),distance);
          end
      end
    end
    image(vidFrame)
%     subplot(1,2,1), image(vidFrame);
%     title('Original');
%     subplot(1,2,2),image(256*out);
%     title('Out');
%     lapse = toc;
%     if lapse > 1/v.FrameRate
%     sprintf('time = %i',lapse)
%     end
    %We ensure the video output has the same frame rate as the original
    pause((1/v.FrameRate));
end