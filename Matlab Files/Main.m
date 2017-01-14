% Clear everything
close all;
clear all;


% Add path of functions (needed for OS X systems) 
addpath(genpath('Image_Transformation'));
addpath(genpath('Kalman'));
addpath(genpath('Particles'));

%Video input file
v = VideoReader('Videos/Pinball.mov');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TUNING INITIALIZATION
% You can modify these parameters to inspect different approaches
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ENDING = 11; % Run the code until this frame (maximum is ENDING = 600)
% If set to 1, the MSE curve is obtain for that method. Set all methods to
% 1 to compare the performance of the three methods.
PARTICLES = 1;
KALMAN = 0;
BOTH = 0;

if ( PARTICLES + KALMAN + BOTH ) > 1
    verbose = 1;
else
    %     verbose = 0 - No output
    %     verbose = 1 - Error plotting
    %     verbose = 2 - Real time video plotting
    verbose = 2;
end


% OBSTACLES = 1 - Some occlusions are added to the original video, in order 
%                 to measure the performance of the filter.
% OBSTACLES = 0 - Original video without occlusions is used
OBSTACLES = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULT PARAMETERS  
% These parameters are to ensure correct visualization of the results. They
% should not be changed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Variable to ensure correct representation of particles and estimated
% states
threshold_square = 30;

% Parameter to decide the colour filtering
colour_thres = 1.55;

% We need this to identify a certain color
c_thres = 12;

% Pixel's size of particles
particle_size = 1;

% Pixel ize of the centroid
c_size = 4;

% Error vectors
errorPF = [];
errorKF = [];
errorPKF = [];


% PARTICLE FILTER
% Get image size x - vertical y - horizontal
[xp,yp,~] = size(readFrame(v));
% Parameter Initialization
[Sp,Rp] = init_Particles(xp,yp);

% KALMAN FILTER
mmodel = 1; % motion model: 0 (constant speed) or 1 (constant acceleration)
[A, R, C, Q] = kalmanInit(1, mmodel);

mu = 0;
muPKF = 0;
Sigma = 0;
SigmaPKF = 0;
error = [];
% Initial measurement
centroid = [1 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN LOOP OVER ALL VIDEO FRAMES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Counter 
count = 0;
while (hasFrame(v) && v.currentTime <= ENDING)
    tic
    
    % Read current frame from video input
    vidFrameOr = readFrame(v); 
        
    % Used to experiment with visual occlusions
    if OBSTACLES
        vidFrame = Video_editing(vidFrameOr);
    else
        vidFrame = vidFrameOr;
    end
    
    % For recording purposes
    %if count == 0 && verbose == 2
    %    figure(1)
    %    image(vidFrame);
    %    disp('Press a key !')  % Pause before starting plotting
    %    pause;
    %end
    
    %Filters the image and transforms it in a binary image. White will
    %represent the most likely regions of target object's pixels
    [RGB, out] = imageTransformation(vidFrame, colour_thres, ...
        [187,187,187],c_thres);

    %Reference image without occlussion use as the real estate of the
    %system to compute the estimation error
    if verbose == 1
        [~, outOr] = imageTransformation(vidFrameOr, colour_thres, ...
            [187,187,187],c_thres, 1);
    end
    
    %Kalman algorithm
    if KALMAN

            % Convolution kernel used to calculate the measurement used by
            % Kalman filter during the update step. 
            Kernel = KernelFunction(0); %[ 0 0 1 1 0 0; 0 1 2 2 1 0; 1 2 3 3 2 1; 1 2 3 ...
                %3 2 1; 0 1 2 2 1 0 ; 0 0 1 1 0 0];
            % Image after convolution
            Out = conv2(single(out),Kernel,'same');
            
            % For analysis purposes
            if v.currentTime == 10.5
                save out.mat Out;
                disp('press any key')
                pause;
            end
            % Variance of this image,used to detect occlusions. If the
            % variance is too low, it will mean that the ball is occluded.
            Var_out = var(Out(Out ~= 0))+ 1e-10;
            % Finds the mode of the Kernel density extraction of the white
            % pixels. 
            [maxA,ind] = max(Out(:));
            [m,n] = ind2sub(size(Out),ind);
     
            % If the ball is fully occluded, we have very poor measurement 
            % and the system should fully trust its predictions, therefore, 
            % the measurement noise has to be considerably big. 
            if Var_out < 40
                distance = 10;
                [A, R, C, Q] = kalmanInit(3, mmodel);
            % If the ball is not occluded, or only partially occluded, the
            % measurement noise is varies with the variance.
            else
                [A, R, C, Q] = kalmanInit(1, mmodel);
                Q = Q/Var_out;
               centroid = [m,n];
                distance = 10;
            end
            % Apply the Kalman filter algorithm
            [mu,Sigma] = KalmanAlgorithm(vidFrame,count, mu, Sigma, ...
                centroid, A, R, C, Q, mmodel);
            % Compute the prediction error, compared to the actual state of
            % the system.
            if verbose == 1
                errorKF = [errorKF, mse_plot( mu(1:2), outOr)]; 
            end
    end
    
    % We will reuse the particle filter algorithm for both the particle
    % filter alone and when used along with Kalman filter
    if PARTICLES || BOTH
            % Apply the particle filter algorithm
            [centroidPart, Sp, vidFrame] = Particle_filter(vidFrame, ...
                out, Sp, Rp);
            % Compute the prediction error compare to the actual state of
            % the system
            if PARTICLES && verbose == 1
                errorPF = [errorPF, mse_plot(centroidPart', outOr)];
            end
            % Combination of Kalman and Particle filter
            if BOTH
                    %As in the Kalman filter, this kernel is used to
                    %calculate the occlusiones.
                    Kernel = KernelFunction(0);% [ 0 0 1 1 0 0; 0 1 2 2 1 0; 1 2 3 3 2 1; ...
                        %1 2 3 3 2 1; 0 1 2 2 1 0 ; 0 0 1 1 0 0];
                    Out = conv2(single(out),Kernel,'same');
                    Var_out = var(Out(Out ~= 0)) + 1e-10;
                    %As in the Kalman
                    if Var_out < 40
                        distanceP = 10;
                        [A, R, C, QPKF] = kalmanInit(3, mmodel);
                    else
                        [A, R, C, QPKF] = kalmanInit(1, mmodel);
                        QPKF = QPKF/Var_out;
                        distanceP = 10;
                    end

                    %Apply the Kalman filter algorithm
                    [muPKF,SigmaPKF] = KalmanAlgorithm(vidFrame,count, ...
                        muPKF, SigmaPKF, centroidPart, A, R, C, QPKF,...
                        mmodel);
                    %Compute the estimation error compared to the actual
                    %state of the system.
                    if verbose == 1
                            errorPKF = [errorPKF, mse_plot(muPKF(1:2), ...
                                outOr)]; 
                    end
            end
    end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLOT OF THE OBJECT TRACKING RESULTS

    if verbose == 2
            figure(1);
            if KALMAN
                 % Print the predicted state in the original frame
                 vidFrame(abs(round(mu(1))-4 + 1):round(mu(1))+4, ...
                     abs(round(mu(2))-4 +1):round(mu(2))+4,1) = 255;
                 vidFrame(abs(round(mu(1))-4 + 1):round(mu(1))+4, ...
                     abs(round(mu(2))-4 +1):round(mu(2))+4,2:3) = 0;
                 % Compute the maximum sizes of the rectangle that will
                 % enclose the ball
                 [max_distance_x_K, max_distance_y_K] = rect_size(xp, ...
                     yp,mu(1),mu(2),threshold_square,distance);
                % Output this image
                %subplot(1,2,1);
                image(vidFrame); axis image;
                %subplot(1,2,2);
                %image(double(RGB)); axis image;
                % Output the enclosing square
                hold on
                rectangle('position',[abs(mu(2)-max_distance_y_K) ...
                    abs(mu(1)-max_distance_x_K) abs(2*max_distance_y_K) ...
                    abs(2*max_distance_x_K)], 'EdgeColor','r')
                hold off
            end  
            if PARTICLES || BOTH
                        % This function represents the particles in the 
                        % binary and original pictures and compute the 
                        % distances of each particle to the centroid in
                        % ascending order
                        [vidFrame, distancePart] = ...
                            particle_distance_and_out(vidFrame, ...
                            Sp,centroidPart,particle_size,c_size );
                        % Print the predicted state
                        vidFrame(abs(round(centroidPart(1))-4 + 1): ...
                            round(centroidPart(1))+4, abs(round(...
                            centroidPart(2))-4 +1):round(centroidPart(2)...
                            )+4, 3) = 255;
                        vidFrame(abs(round(centroidPart(1))-4 + 1):...
                            round(centroidPart(1))+4, abs(round(...
                            centroidPart(2))-4 +1):round(centroidPart(...
                            2))+4, 1:2) = 0;
                        % Square's max size
                        [max_distance_x, max_distance_y] = rect_size(...
                            xp, yp, centroidPart(1), centroidPart(2), ...
                            threshold_square,distancePart,Sp);
                    if PARTICLES
                        % Output the edited frame
                        image(vidFrame); axis image;
                        hold on
                        rectangle('position', [abs(centroidPart(2)-...
                            max_distance_y) abs(centroidPart(1)-...
                            max_distance_x) abs(2*max_distance_y) ...
                            abs(2*max_distance_x)], 'EdgeColor','b')
                        hold off
                    end
                    if BOTH
                        % Print the estimated estate
                        vidFrame(abs(round(muPKF(1))-4 + 1):...
                            round(muPKF(1))+4,abs(round(muPKF(2))-4 +1)...
                            :round(muPKF(2))+4,1) = 255;
                        vidFrame(abs(round(muPKF(1))-4 + 1):...
                            round(muPKF(1))+4,abs(round(muPKF(2))-4 +1):...
                            round(muPKF(2))+4,2:3) = 0;
                        % Square's max size
                        [max_distance_xK, max_distance_yK] = ...
                            rect_size(xp, yp, muPKF(1), muPKF(2), ...
                            threshold_square,10);
                        % Output the edited frame
                        image(vidFrame); axis image;
                        hold on
                        rectangle('position',[abs(centroidPart(2)-...
                            max_distance_y) abs(centroidPart(1)...
                            -max_distance_x) abs(2*max_distance_y) ...
                            abs(2*max_distance_x)], 'EdgeColor','b')
                        rectangle('position',[abs(muPKF(2)-...
                            max_distance_yK) abs(muPKF(1)-...
                            max_distance_xK) abs(2*max_distance_yK) ...
                            abs(2*max_distance_xK)], 'EdgeColor','r')
                        hold off
                    end
            end
        % To ensure a correct output Frame rate
        pause(abs((1/v.FrameRate)-toc));
    end
    % Used in KF to compute the initial variables
    count = count + 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SQUARE ERROR PLOTS

if verbose == 1
        figure(1);
        hold on;
        title('Mean Square Error')
        xlabel('Frame number')
        ylabel('Squared euclidean distance')
        grid on
        if PARTICLES
            plot(errorPF(10:end), 'DisplayName', 'Particle Filter');
            sprintf('MSE PF = %d', mean(errorPF))
        end
        if KALMAN
            plot(errorKF(10:end), 'DisplayName', 'Kalman Filter');
            sprintf('MSE KF = %d', mean(errorKF))
        end
        if BOTH
            plot(errorPKF(10:end),'DisplayName', 'Combined Filter');
            sprintf('MSE combined = %d', mean(errorPKF))
        end
        legend('show');
end

