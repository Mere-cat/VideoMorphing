# **Computer Vision Final Project**

408125029 資工三 王禮芳

## 1. Method description

### 1. 讀入影片

```matlab
v1 = VideoReader('../../video/408410037.mp4');
myVideo = VideoReader('../../video/408125029.mp4');
```

### 2. 每幀morphing

這部份會拿上一個同學的最後15幀 morph 自己的前15幀，以一個迭代15次的迴圈進行每一幀的 morphing。

我們在每個迴圈中，會把當前 frame 取特徵點，而後依據目前的 alpha 產生一張 morphing 後的圖片。迴圈結束後，我們就有了15幀從前一位同學到我的中繼漸變照片。

```matlab
imgNum = 15;
for i = 1:imgNum
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
```

### 3. 輸出影片

我用 matlab 串接，先把前一位同學從頭到最後倒數15幀的地方用 videoWriter 寫入目標輸出影片，而後把那15幀加進去，最後串接上我的影片（從第16幀開始）：

```matlab
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
```

## 2. Experimental results

結果的影片與照片在雲端：https://drive.google.com/drive/folders/17vvrdpzjgilmcyiyn85JpKrn9-Om4D0N?usp=sharing

影片檔名是 `morphing_v2.avi`（我的matlab無法直接輸出 mp4），morphing 大約在2:42~2:43的地方。

我自己覺得臉的效果還可以，但身體真的差強人意，我們的身體部份差異頗多（我是低領，同學領子小滿多、同學肩膀上有馬尾而我沒有），致使特徵點很找，而結果就不太好。

## 3. Discussion

這時才突然發現 video morphing 和 image morphing 串接成影片的差異，原本 final project 的作法會讓串接後的影片長度大於兩者相加，因為中間多了 morphing 過去的地方，但 video morphing 感覺就像是影片一邊進行，而 morphing 也在持續發揮作用，和我在 final project 的作法相比，video morphing 確實更為理想（但做出來的效果是另外一回事qq）。

## 4. Problem and difficulties

### 找特徵點

我原來的 final project 的實做方式是手動找特徵點，但這在 video morphing 較麻煩了：如果我們每張照片找100個左右的特徵點，而總共要  morphing 15 幀，那就要手動點一千多個點，而且有時出來的效果不太好，還要重新找一次。

這次的 final project 我來來回回，反覆修改感覺怪怪的某幾幀，做完手好像要壞掉了。

這也讓我徹底體會自動標記特徵點的重要性。
