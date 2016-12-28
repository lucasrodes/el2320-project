function [RGB ,out_bin] = imageTransformation( original_im, colour_thres,color, c_thres)

if nargin < 3
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
else
    if nargin < 4
        c_thres = 50;
    end
    %Get rgb values
    r = original_im(:, :, 1);
    g = original_im(:, :, 2);
    b = original_im(:, :, 3);
    %colour_thresholds
    green = (g <= (color(1) + c_thres)).*(g > (color(1) - c_thres));
    red = (r <= (color(2) + c_thres)).*(r > (color(2) - c_thres));
    blue = (b <= (color(3) + c_thres)).*(b > (color(3) - c_thres));
    
    %Binary pic
    out_bin = green.*red.*blue;
    
    %We smooth the edges and fill the gaps
    out_bin = bwareaopen(out_bin,60);
    se = strel('disk',2);
    out_bin = imclose(out_bin,se);
    out_bin = imfill(out_bin,'holes');
    out_bin = imclearborder(out_bin);
    
    %Conver to RGB
    grayImage = 255 * uint8(out_bin);
    RGB = cat(3, grayImage, grayImage, grayImage);
    
end