%% params
alpha = 10;
lowCutoff = 50/60;
highCutoff = 60/60;
lambdaC = 16;
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

framesOut = lpiir(frames, alpha, lambdaC, lowCutoff, highCutoff);

%% save video file
outName = 'out';
vidOut = VideoWriter(outName);
vidOut.FrameRate = vidIn.FrameRate;

open(vidOut)

for i=startIndex:endIndex
    % Convert YIC to RGB color space
    rgbframe = ntsc2rgb(frames(:,:,:,i));
    progmeter(i,endIndex);
    % Clamp values to [0,1]
    rgbframe(rgbframe < 0) = 0;
    rgbframe(rgbframe > 1) = 1;
    
    writeVideo(vidOut, im2uint8(rgbframe));
end
close(vidOut);
disp('wrote video file');
% TODO make videos  baby and deadface