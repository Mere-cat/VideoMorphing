% 1. Read video ===========================================================
v1 = VideoReader('../../video/408410037.mp4');
myVideo = VideoReader('../../video/408125029.mp4');

% 2. Video morphing: generate 15 images during the morphing ===============
imgNum = 15;
for i = 14:14
    alpha = i / imgNum;
    
    % 2.1 Obtain each frame from the two video
    v1Frame = read(v1,v1.NumFrames - i + 1);
    myFrame = read(myVideo,i);
    
    % 2.2 Select the key points from two frames
    [v1_pts, my_pts] = cpselect(v1Frame, myFrame, 'Wait', true);
    v1_pts = [v1_pts; [1,1]; [size(v1Frame,2),1]; [size(v1Frame,2),size(v1Frame,1)]; [1,size(v1Frame,1)]];
    my_pts = [my_pts; [1,1]; [size(myFrame,2),1]; [size(myFrame,2),size(myFrame,1)]; [1,size(myFrame,1)]];
    
    % 2.3 create the delaunary triangle
    pts_mean = (v1_pts + my_pts) / 2;
    tri = delaunay(pts_mean);

    % 2.4 Generate each frame
    resFrame = morph_triangle(v1Frame, myFrame, v1_pts, my_pts, tri, alpha, alpha);

    % 2.5 Output one frame as a .png file
    fileName = "../image/img" + i + ".png";
    imwrite(resFrame, fileName);
end

% 3. Output the video (morphing part)======================================
video = VideoWriter('../morphing_v2.avi'); %create the video object
video.FrameRate = 30;
open(video); %open the file for writing

% The original video deleted the last 15 frames
for i = 1:v1.NumFrames - imgNum
    videoFrame = read(v1,i);  
    writeVideo(video,videoFrame);
end

% The morphing video (15 frames)
for i = 1:imgNum
    filename = "../image/img" + i + ".png";
    I = imread(filename); %read the next image
    writeVideo(video,I); %write the image to file
end

% My video deleted the first 15 frames
for i = 6:myVideo.NumFrames
    videoFrame = read(myVideo, i);  
    writeVideo(video,videoFrame);
end

close(video); %close the file
