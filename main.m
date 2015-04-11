%% params
alpha = 0;
lowCutoff = 1/100;
highCutoff = 1/10;
lambdaC = 0;
filename = 'face.mp4';

%% read file

vidIn = VideoReader(filename);
startIndex = 1;
endIndex = vidIn.NumberOfFrames;
nChannels = 3;
temp = struct('cdata', ...
		  zeros(vidIn.Height, vidIn.Width, nChannels, 'uint8'), ...
		  'colormap', []);
      
frames = zeros(vidIn.Height, vidIn.Width, nChannels, endIndex);
for i=startIndex:endIndex
    temp.cdata = read(vidIn, i);
    [rgbframe,~] = frame2im(temp);
    rgbframe = im2double(rgbframe);
    frame = rgb2ntsc(rgbframe);
    frames(:,:,:,i) = frame;
end

%% magnify motion

framesOut = lpiir(frames, alphga, lamdaC, lowCutoff, highCutoff);

%% save video file
outName = 'out';
vidOut = VideoWriter(outName);
vidOut.FrameRate = vidIn.FrameRate;

open(vidOut)

for i=startIndex:endIndex
    % Convert YIC to RGB color space
    rgbframe = ntsc2rgb(frames(:,:,:,i));
    
    % Clamp values to [0,1]
    rgbframe(rgbframe < 0) = 0;
    rgbframe(rgbframe > 1) = 1;
    
    writeVideo(vidOut, im2uint8(rgbframe));
end
close(vidOut);

% TODO make videos  baby and deadface