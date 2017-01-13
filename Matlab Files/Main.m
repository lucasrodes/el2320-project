%% Section - Only Particle Filter

%Clear everything
clear all;
close all;

PARTICLES = 1;
KALMAN = 0;
BOTH = 0;

if ( PARTICLES + KALMAN + BOTH ) > 1
    verbose = 1;
else
    %Set: verbose = 0 - No output
    %     verbose = 1 - Error plotting
    %     verbose = 2 - Real time video plotting
    verbose = 2;
end

%Path 
addpath(genpath('Image_Transformation'));
addpath(genpath('Kalman'));
addpath(genpath('Particles'));

%Set OBSTACLES to one if some areas want to be erased to the performance of
%the filters when occlusions occur
OBSTACLES = 1;

%Video input file
v = VideoReader('Videos/NES_Longplay_[456_Pinball.mov');

%Specify when in the video (in s) should the program start reading
v.CurrentTime = 261;

%Set the finishing time. Length then will be ENDING - v.CurrentTime
ENDING = 290;

%Variable to ensure correct representation of particles and estimated
%estates
threshold_square = 30;

%Parameter to decide the colour filtering
colour_thres = 1.55;

%We need this to identify a certain color
c_thres = 12;

%Pixel's size of particles
particle_size = 1;

%Pixel size of the centroid
c_size = 4;

%Error vectors
errorPF = [];
errorKF = [];
errorPKF = [];

%%%%%%%%%%%%%%%%%%%
%%PArticle filter%%
%%%%%%%%%%%%%%%%%%%

%Get image size x - vertical y - horizontal
[xp,yp,~] = size(readFrame(v));
% Parameter Initialization
[Sp,Rp] = init_Particles(xp,yp);

%%%%%%%%%%%%%%%%%
%%Kalman filter%%
%%%%%%%%%%%%%%%%%

%Counter 
count = 0;

%Parameters initialization

mmodel = 0; % motion model: 0 (constant speed) or 1 (constant acceleration)
[R,Q,A,C] = kalmanInit(1, mmodel);

mu = 0;
muPKF = 0;
Sigma = 0;
SigmaPKF = 0;
error = [];
%Initial measurement
centroid = [1 1];

%Main loop over each video frame
while (hasFrame(v) && v.currentTime <= ENDING)
    
    tic
    
    %Read current frame from video input
    vidFrameOr = readFrame(v); 
        
    %Used to experiment with visual occlusions
    if OBSTACLES
        vidFrame = Video_editing(vidFrameOr);
    else
        vidFrame = vidFrameOr;
    end
    
    %Filters the image and transforms it in a binary image. White will
    %represent the most likely regions of target object's pixels
    [RGB, out] = imageTransformation(vidFrame,colour_thres,[187,187,187],c_thres);
    
    if verbose == 1
        [~, outOr] = imageTransformation(vidFrameOr,colour_thres,[187,187,187],c_thres);
    end

    if KALMAN

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
            %Apply the Kalman filter algorithm
            [mu,Sigma] = KalmanAlgorithm(vidFrame,count, mu, Sigma, centroid, ...
                                                       A, R, C, Q, mmodel);
            if verbose == 1
                errorKF = [errorKF, mse_plot( mu(1:2), outOr)]; 
            end
    end
    if PARTICLES || BOTH
            %Apply the particle filter algorithm
            [centroidPart, Sp,vidFrame] = Particle_filter(vidFrame, RGB, out, Sp, Rp , verbose);
            if PARTICLES && verbose == 1
                    errorPF = [errorPF, mse_plot( centroidPart, outOr)]; 
            end
            if BOTH
                    %Compute the number of white pixels in the image to calculate the
                    %oclusion
                    w_pix = sum(sum(out));
                    %Option B
                    if w_pix < 70
                        param = 3;
                    elseif w_pix < 100
                        param = 2;
                    else
                        param = 1;
                    end
                    %Parameters initialization
                    [R,QPKF,A,C] = kalmanInit(param, mmodel);
                    %Apply the Kalman filter algorithm
                    [muPKF,SigmaPKF] = KalmanAlgorithm(vidFrame,count, muPKF, SigmaPKF, centroidPart', ...
                                                                   A, R, C, QPKF, mmodel);
                    if verbose == 1
                            errorPKF = [errorPKF, mse_plot( muPKF(1:2), outOr)]; 
                    end
                end
        end

    if verbose == 2
            if KALMAN
                 %Print the estimated estate
                 vidFrame(abs(round(mu(1))-4 + 1):round(mu(1))+4,abs(round(mu(2))-4 +1):round(mu(2))+4,1) = 255;
                 vidFrame(abs(round(mu(1))-4 + 1):round(mu(1))+4,abs(round(mu(2))-4 +1):round(mu(2))+4,2:3) = 0;

                 [max_distance_x_K, max_distance_y_K] = rect_size(xp,yp,mu(1),mu(2),threshold_square,distance);
                %image(RGB); axis image;
            
                hold on
                rectangle('position',[abs(mu(2)-max_distance_y_K) abs(mu(1)-max_distance_x_K) abs(2*max_distance_y_K) abs(2*max_distance_x_K)], 'EdgeColor','r')
                hold off
            end  
            if PARTICLES || BOTH
                        %This function represents the particles in the binary and original
                        %pictures and compute the distances of each particle to the centroid in
                        %ascending order
                        [vidFrame, RGB, distanceP] = particle_distance_and_out( vidFrame ,RGB, Sp,centroidPart,particle_size,c_size );

                        vidFrame(abs(round(centroidPart(1))-4 + 1):round(centroidPart(1))+4,abs(round(centroidPart(2))-4 +1):round(centroidPart(2))+4,3) = 255;
                        vidFrame(abs(round(centroidPart(1))-4 + 1):round(centroidPart(1))+4,abs(round(centroidPart(2))-4 +1):round(centroidPart(2))+4,1:2) = 0;

                        [max_distance_x, max_distance_y] = rect_size(xp,yp,centroidPart(1),centroidPart(2),threshold_square,distanceP,Sp);
                    if PARTICLES
                        image(RGB); axis image;
                        hold on
                        rectangle('position',[abs(centroidPart(2)-max_distance_y) abs(centroidPart(1)-max_distance_x) abs(2*max_distance_y) abs(2*max_distance_x)], 'EdgeColor','b')
                        hold off
                    end
                    if BOTH
                        %Print the estimated estate
                        vidFrame(abs(round(muPKF(1))-4 + 1):round(muPKF(1))+4,abs(round(muPKF(2))-4 +1):round(muPKF(2))+4,1) = 255;
                        vidFrame(abs(round(muPKF(1))-4 + 1):round(muPKF(1))+4,abs(round(muPKF(2))-4 +1):round(muPKF(2))+4,2:3) = 0;
                        [max_distance_xK, max_distance_yK] = rect_size(xp,yp,muPKF(1),muPKF(2),threshold_square,distanceP,Sp);
                    %image(vidFrame); axis image;
    
                    hold on
                    rectangle('position',[abs(centroidPart(2)-max_distance_y) abs(centroidPart(1)-max_distance_x) abs(2*max_distance_y) abs(2*max_distance_x)], 'EdgeColor','b')
                    rectangle('position',[abs(muPKF(2)-max_distance_yK) abs(muPKF(1)-max_distance_xK) abs(2*max_distance_yK) abs(2*max_distance_xK)], 'EdgeColor','r')
                    hold off
                    end
            end
        pause(abs((1/v.FrameRate)-toc));
    end
    count = count + 1;
end

if verbose == 1
        figure(1);
        hold on;
        title('Mean Square Error')
        xlabel('Frame number')
        ylabel('Squared euclidean distance')
        grid on
        if PARTICLES
            plot(errorPF(10:end), 'DisplayName', 'Particle Filter');
            mean(errorPF)
        end
        if KALMAN
            plot(errorKF(10:end), 'DisplayName', 'Kalman Filter');
            mean(errorKF)
        end
        if BOTH
            plot(errorPKF(10:end),'DisplayName', 'Combined Filter');
            mean(errorPKF)
        end
        legend('show');
end

