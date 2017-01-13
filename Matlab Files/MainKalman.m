clear all;
close all;

%set to one if some areas want to be erased to check how god does the
%kalman filter works
OBSTACLES = 1;

%Video input file
v = VideoReader('Videos/NES_Longplay_[456_Pinball.mov');

%Specify that reading should begin 2.5 seconds from the beginning of the video.
v.CurrentTime = 254;

%Parameter to decide the colour filtering
colour_thres = 1.55;

%Flag to differenciate the first iteration from the following
count = 0;

%We need this to identify a certain color
c_thres = 12;

%Get image size x - vertical y - horizontal
[xp,yp,~] = size(readFrame(v));

%Size of the centroid
c_size = 4;

threshold_square = 30;

%%%%%%%%%%%%%%%%%
%%Kalman filter%%
%%%%%%%%%%%%%%%%%

%Parameters initialization
mmodel = 0; % motion model: 0 (constant speed) or 1 (constant acceleration)
[R,Q,A,C] = kalmanInit(1, mmodel);

while hasFrame(v)
    
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
    
    [B,L] = bwboundaries(out,'noholes');
    %Check roundness
    stats = regionprops(L,'Area','Centroid');
    %Compute the number of white pixels in the image to calculate the
    %oclusion
    w_pix = sum(sum(out));
    %Option B
    if w_pix < 10
        centroid = centroid;
        distance = 0;
        param = 3;
    elseif w_pix < 70
        param = 3;
        centroid(1) = round(stats(1).Centroid(2));
        centroid(2) = round(stats(1).Centroid(1));
        distance = sqrt(round(stats(1).Area)/pi);
    elseif w_pix < 100
        param = 2;
        centroid(1) = round(stats(1).Centroid(2));
        centroid(2) = round(stats(1).Centroid(1));
        distance = sqrt(round(stats(1).Area)/pi);
    else
        param = 1;
        centroid(1) = round(stats(1).Centroid(2));
        centroid(2) = round(stats(1).Centroid(1));
        distance = sqrt(round(stats(1).Area)/pi);
    end
    %Parameters initialization
    [R,Q,A,C] = kalmanInit(param, mmodel);
    [count,mu,Sigma] = KalmanAlgorithm(count, mu, Sigma, z, ...
                                               A, R, C, Q, mmodel);
    % (1) If we are at t = 0, we obtain the centroid and set it as 
    % the initial point. We use a variable count to know at which 
    % time step are we currently.
    if count == 0
        mu = centroid;
        x0 = centroid; % initial position (t=0)
        count = count+1;
    % (2) When we are at t=1, we are able to obtain the initial
    % speed as the difference of the position at t=1 and t=0.
    % Next, we also initialize the initial covariance matrix
    % with an arbitrary value (high, since we are at the
    % beginning and we are not really sure!)
    elseif  count == 1
        x1 = centroid; % position at t=1
        vv1 = x1 - x0; % speed at t=1
        if mmodel == 0
            x = [x1(1); x1(2); vv1(1); vv1(2)]; % Initial state
            Sigma = 10*eye(4); % Uncertainty at the beginning
            % Prediction step
            [mu_bar, Sigma_bar] = kalmanPredict(x, Sigma, A, R);
            z = x1; % obtain measure (should be from PF)
            % Update step
            [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z', C, Q);
            count = count+2;
        else
            count = count+1;
        end
    % (3) Similar as in (2), we now are able to obtain the initial
    % acceleration as the difference of the speed at t=1 and t=0. We also
    % initialize the initial covariance matrix, which is now 6X6, with
    % hight determinant, since is the beginning and we are not really sure
    % about the state.
    elseif  count == 2
        x2 = centroid; % position at t=2
        vv2 = x2 - x1; % speed at t=2
        aa = vv2 - vv1; % initial acceleration
        x = [x2(1); x2(2); vv2(1); vv2(2); aa(1) ; aa(2)]; % Initial state
        Sigma = 10*eye(6); % Uncertainty at the beginning
        % Prediction step
        [mu_bar, Sigma_bar] = kalmanPredict(x, Sigma, A, R);
        z = x2; % obtain measure (should be from PF)
        % Update step
        [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
        count = count+1;
    % (4) We enter this whenever t>2.
    else
        % Prediction step
        [mu_bar, Sigma_bar] = kalmanPredict(mu, Sigma, A, R);

        % Measurement 
        z = centroid';

        % Update step
        [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
        count = count+1; 
    end

    if mu(1) >= xp - 4
        mu(1) = xp - 4;
    end
    if mu(2) >= yp - 4
         mu(2) = yp - 4;
    end
    vidFrame(abs(round(mu(1))-4 + 1):round(mu(1))+4,abs(round(mu(2))-4 +1):round(mu(2))+4,3) = 255;
    vidFrame(abs(round(mu(1))-4 + 1):round(mu(1))+4,abs(round(mu(2))-4 +1):round(mu(2))+4,1:2) = 0;
    RGB(abs(round(mu(1))-4 + 1):round(mu(1))+4,abs(round(mu(2))-4 +1):round(mu(2))+4,1:2) = 0;
    RGB(abs(round(mu(1))-4 + 1):round(mu(1))+4,abs(round(mu(2))-4 +1):round(mu(2))+4,3) = 255;
   
    [max_distance_x_K, max_distance_y_K] = rect_size(xp,yp,mu(1),mu(2),threshold_square,distance);

   image(vidFrame); axis image;
    
    %For other outputs
%     subplot(1,2,1); image(RGB); axis image
%     hold on
%     %rectangle('position',[abs(mu(2)-max_distance_y_K) abs(mu(1)-max_distance_x_K) abs(2*max_distance_y_K) abs(2*max_distance_x_K)], 'EdgeColor','g')
%     %hold off
%     subplot(1,2,2); image(vidFrame); axis image
    hold on
    rectangle('position',[abs(mu(2)-max_distance_y_K) abs(mu(1)-max_distance_x_K) abs(2*max_distance_y_K) abs(2*max_distance_x_K)], 'EdgeColor','g')
    hold off

    %We ensure the video output has the same frame rate as the original
    pause((1/v.FrameRate));
   
end