function [RGB ,out_bin] = imageTransformation( original_im, colour_thres)
    
    %Get rgb values
    r = original_im(:, :, 1);
    g = original_im(:, :, 2);
    b = original_im(:, :, 3);
    
    %colour_thresholds
    justGreen = g - r/colour_thres - b/colour_thres;
    justRed = r - g/colour_thres - b/colour_thres;
    justBlue = b - r/colour_thres - g/colour_thres;
    
    %To gray
    green = justGreen > 40;
    red = justRed > 40;
    blue = justBlue > 40;
    %Binary pic
    out_bin = green + red + blue;
    grayImage = 255 * uint8(out_bin);
    RGB = cat(3, grayImage, grayImage, grayImage);
    
end