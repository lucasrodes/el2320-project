function [in_image, distance] = particle_distance_and_out( in_image, S, centroid, particle_size, c_size )
        
     %This function is used to output the cloud of particles and calculate
     %the distance of the most distant particle
     for i=1:size(S,2)

           %We erase first
           in_image(abs(S(1,i)-round(particle_size/2)+1):S(1,i)+round(particle_size/2),...
               abs(S(2,i)-round(particle_size/2)+1):S(2,i)+round(particle_size/2),3) = 0;
           in_image(abs(S(1,i)-round(particle_size/2)+1):S(1,i)+round(particle_size/2),...
               abs(S(2,i)-round(particle_size/2)+1):S(2,i)+round(particle_size/2),1) = 0;
           
           %We paint the particles
           in_image(abs(S(1,i)-round(particle_size/2)+1):S(1,i)+round(particle_size/2),...
               abs(S(2,i)-round(particle_size/2)+1):S(2,i)+round(particle_size/2),2) = 255;

           %Calculate distances to centroid
           distance(i) = sqrt((S(1,i)-centroid(1)).^2 + (S(2,i)-centroid(2)).^2);

     end
    %Paint the centroid
    in_image(abs(round(centroid(1)-round(c_size/2))):round(centroid(1)+round(c_size/2)),...
        round(abs(centroid(2)-round(c_size/2))):round(centroid(2)+round(c_size/2)),1:3) = 255;
    
    %The particles are order with increasing distance to compute the final
    %rectangle
    distance = sort(distance);
end