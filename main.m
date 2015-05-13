%% params
alpha = 10;
lowCutoff = 0.4;
highCutoff = 0.05;
lambdaC = 16;
chromAtt = 0.1;
filename = 'wrist.mp4';

% TODO explain params, give some examples
% TODO motion magnification only inside a mask?

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
    % Convert RGB to YIC color space
    frame = rgb2ntsc(rgbframe);
    frames(:,:,:,i) = frame;
end

%% magnify motion (all operations work on YIC-double image pyramid frames)

framesOut = lpiir(frames, alpha, lambdaC, lowCutoff, highCutoff, chromAtt);

%% save video file
outName = 'out';
vidOut = VideoWriter(outName);
vidOut.FrameRate = vidIn.FrameRate;

open(vidOut)

for i=startIndex:endIndex
    % Convert YIC to RGB color space
    rgbframe = ntsc2rgb(framesOut(:,:,:,i));
    progmeter(i,endIndex);
    % Clamp values to [0,1]
    rgbframe(rgbframe < 0) = 0;
    rgbframe(rgbframe > 1) = 1;
    
    writeVideo(vidOut, rgbframe);
end
close(vidOut);
disp('wrote video file');