function frame = GetFramesFromVideo(index)
    %Video object
    v = VideoReader('Bouncing_Ball_Reference.avi');
    frame = read(v,index);
    
    
end