function in = Video_editing(in)
    %This function is used to add the occlusions to each frame
    %First we erase the color
    in( 200:230,160:190,1) = 0; 
    in( 200:230,280:310,1) = 0; 
    in( 265:295,185:290,1) = 0; 
    %And then we add the desire color
    in( 200:230,160:190,2:3) = 255; 
    in( 200:230,280:310,2:3) = 255; 
    in( 265:295,185:280,2:3) = 255;
end
