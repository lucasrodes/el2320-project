function [in_image, binary_Image, distance] = particle_distance_and_out( in_image, binary_Image , S, centroid, particle_size, c_size )

     for i=1:size(S,2)

           %We paint the particles
           binary_Image(abs(S(1,i)-round(particle_size/2)+1):S(1,i)+round(particle_size/2),...
               abs(S(2,i)-round(particle_size/2)+1):S(2,i)+round(particle_size/2),2) = 255;
           binary_Image(abs(S(1,i)-round(particle_size/2)+1):S(1,i)+round(particle_size/2),...
               abs(S(2,i)-round(particle_size/2)+1):S(2,i)+round(particle_size/2),1) = 0;
           in_image(abs(S(1,i)-round(particle_size/2)+1):S(1,i)+round(particle_size/2),...
               abs(S(2,i)-round(particle_size/2)+1):S(2,i)+round(particle_size/2),1:2) = 255;

           %Calculate distances to centroid
           distance(i) = sqrt((S(1,i)-centroid(1)).^2 + (S(2,i)-centroid(2)).^2);

     end
    %Paint the centroid
    binary_Image(abs(round(centroid(1)-round(c_size/2))):round(centroid(1)+round(c_size/2)), ...
        round(abs(centroid(2)-round(c_size/2))):round(centroid(2)+round(c_size/2)),3) = 255;
    binary_Image(abs(round(centroid(1)-round(c_size/2))):round(centroid(1)+round(c_size/2)),...
        round(abs(centroid(2)-round(c_size/2))):round(centroid(2)+round(c_size/2)),1) = 0;
    in_image(abs(round(centroid(1)-round(c_size/2))):round(centroid(1)+round(c_size/2)),...
        round(abs(centroid(2)-round(c_size/2))):round(centroid(2)+round(c_size/2)),1) = 255;
    
    %The particles are order with increasing distance to compute the final
    %rectangle
    distance = sort(distance);
end