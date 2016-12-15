clear all;
close all;
%Video input file
v = VideoReader('Bouncing_Ball_Reference.avi');

%Specify that reading should begin 2.5 seconds from the beginning of the video.
v.CurrentTime = 45;

%Parameter to decide the colour filtering
colour_thres = 1.55;

%Needed to output the pictures in gray format
colormap(gray(256));

%Flag to differenciate the first iteration from the following
count = 0;

%%%%%%%%%%%%%%%%%%%
%%Particle filter%%
%%%%%%%%%%%%%%%%%%%

%Size of the particles
particle_size = 2;

%Size of the centroid
c_size = 12;

%outputVideo = VideoWriter('out.avi');
threshold_square = 15;

%Get image size x - vertical y - horizontal
[xp,yp,~] = size(readFrame(v));
% Parameter Initialization
[Sp,Rp,Qp,Lambda_psi] = init_Particles(xp,yp);


%%%%%%%%%%%%%%%%%
%%Kalman filter%%
%%%%%%%%%%%%%%%%%

%Parameters initialization
[R,Q,A,C] = kalmanInit();

while hasFrame(v)
    %Frame matrix
    vidFrame = readFrame(v); 
    tic
    
    %Filters the image and transforms it in a binary image. White will
    %represent high intensity colours and black the background. The put put
    %format is RGB so we can represent colorful particles
    [RGB, out] = imageTransformation(vidFrame,colour_thres);

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
    
    %Calculate the max size of the square that will be painted around the
    %object
    
    max_distance_x = distance(size(Sp,2) - threshold_square);
    max_distance_y = distance(size(Sp,2) - threshold_square);
    if centroid(1) > xp/2
        if max_distance_x > xp - centroid(1)
            max_distance_x = round(xp-centroid(1) - 1);
        end
    elseif centroid(1) <= xp/2
        if max_distance_x > centroid(1)
            max_distance_x = round(centroid(1) - 1);
        end
    end
    if centroid(2) > yp/2
        if max_distance_y > yp - centroid(2)
            max_distance_y = round(yp-centroid(2) - 1);
        end
    elseif centroid(2) <= yp/2
        if max_distance_y > centroid(2)
            max_distance_y = round(centroid(2) - 1);
        end
    end
    
    % (1) If we are at t = 0, we obtain the centroid and set it as 
    % the initial point. We use a variable count to know at which 
    % time step are we currently.
    if count == 0
        mu = centroid;
        x1 = centroid; % initial position (t=0)
        count = count+1;
    % (2) When we are at t=1, we are able to obtain the initial
    % speed as the difference of the position at t=1 and t=0.
    % Next, we also initialize the initial covariance matrix
    % with an arbitrary value (high, since we are at the
    % beginning and we are not really sure!)
    elseif  count == 1
        x2 = centroid; % position at t=1
        vv = x2 - x1; % initial speed
        x = [x2(1); x2(2); vv(1); vv(2)]; % Initial state
        Sigma = 10*eye(4); % Uncertainty at the beginning
        % Prediction step
        [mu_bar, Sigma_bar] = kalmanPredict(x, Sigma, A, R);
        z = x2; % obtain measure (should be from PF)
        % Update step
        [mu, Sigma] = kalmanUpdate(mu_bar, Sigma_bar, z, C, Q);
        count = count+1;
    % (3) We enter this whenever t>=1. We proceed as following. 
    else
        % Prediction step
        [mu_bar, Sigma_bar] = kalmanPredict(mu, Sigma, A, R);

        % Measurement (should come from Particle Filter)
        z = centroid;


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
     vidFrame(round(mu(1))-4:round(mu(1))+4,round(mu(2))-4:round(mu(2))+4,1:2) = 256;
     RGB(round(mu(1))-4:round(mu(1))+4,round(mu(2))-4:round(mu(2))+4,:) = 0;
     RGB(round(mu(1))-4:round(mu(1))+4,round(mu(2))-4:round(mu(2))+4,3) = 256;

    
    subplot(2,1,1); image(RGB); axis image
    hold on
    rectangle('position',[centroid(2)-max_distance_y centroid(1)-max_distance_x 2*max_distance_y 2*max_distance_x], 'EdgeColor','r')
%     hold on
%     rectangle('position',[mu(2)-max_distance mu(1)-max_distance 2*max_distance 2*max_distance], 'EdgeColor','g')
    hold off
    subplot(2,1,2); image(vidFrame); axis image
    hold on
    rectangle('position',[centroid(2)-max_distance_y centroid(1)-max_distance_x 2*max_distance_y 2*max_distance_x], 'EdgeColor','r')
    hold on
%     rectangle('position',[mu(2)-max_distance mu(1)-max_distance 2*max_distance 2*max_distance], 'EdgeColor','g')
%     hold off
    %We ensure the video output has the same frame rate as the original
    pause((1/v.FrameRate));
   
end