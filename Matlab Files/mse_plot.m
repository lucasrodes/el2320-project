function error = mse_plot( estimated_st, out)
   
    [~,L] = bwboundaries(out,'noholes');
    %Check roundness
    stats = regionprops(L,'Area','Centroid');
    %Compute the number of white pixels in the image to calculate the
    %oclusion
    w_pix = sum(sum(out));
    if w_pix >= 10
        centroid(1) = round(stats(1).Centroid(2));
        centroid(2) = round(stats(1).Centroid(1));
    end
    error = norm(centroid-estimated_st);
    error = error*error;
end