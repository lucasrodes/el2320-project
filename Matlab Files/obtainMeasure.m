function centroid = obtainMeasure()

clear all;
close all;
%Video input file
v = VideoReader('Main_code/Bouncing_Ball_Reference.avi');

%Specify that reading should begin 2.5 seconds from the beginning of the video.
v.CurrentTime = 45;

colormap(gray(256));

count = 0;
[R,Q,A,C] = kalmanInit();
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
            % We detect the measurement (Now using raw image processing)
            centroid(k,:) = round(stats(k).Centroid);
            
            % (1) If we are at t = 0, we obtain the centroid and set it as 
            % the initial point. We use a variable count to know at which 
            % time step are we currently.
            if count == 0
                x1 = centroid; % initial position (t=0)
                count = count+1;
            else
                % (2) When we are at t=1, we are able to obtain the initial
                % speed as the difference of the position at t=1 and t=0.
                % Next, we also initialize the initial covariance matrix
                % with an arbitrary value (high, since we are at the
                % beginning and we are not really sure!)
                if count == 1
                    x2 = centroid; % position at t=1
                    vv = x2 - x1; % initial speed
                    x = [x2(1); x2(2); vv(1); vv(2)]; % Initial state
                    Sigma = 10*eye(4); % Uncertainty at the beginning
                    % Prediction step
                    [mu_bar, Sigma_bar] = kalmanPredict(x, Sigma, A, R);
                    z = x2'; % obtain measure (should be from PF)
                    % Update step
                    [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
                    count = count+1;
                % (3) We enter this whenever t>=1. We proceed as following. 
                else
                    % Prediction step
                    [mu_bar, Sigma_bar] = kalmanPredict(x, Sigma, A, R);
                    
                    % Measurement (should come from Particle Filter)
                    z = centroid';
                    z = z(:,1);
                    
                    % Update step
                    [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
                    count = count+1;
                end

                vidFrame((mu(2)-4:mu(2)+4),(mu(1)-4:mu(1)+4),:) = 256;
                %vidFrame((centroid(k,2)-4:centroid(k,2)+4),(centroid(k,1)-4:centroid(k,1)+4),:) = 256;
                distance = sqrt(area/pi);
                vidFrame = drawCircle(vidFrame,mu(2),mu(1),distance);
            end
         end
      end
    end
    image(vidFrame)

    %We ensure the video output has the same frame rate as the original
    pause((1/v.FrameRate));
   
end

end