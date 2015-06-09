function eulermag ( filein, fileout, alpha, lambdaC, lowCutoff, highCutoff, chromAtt, exaggerationFactor, maxframes ) 
% Reads the input video file, awaits user input for magnification area 
% selection, then converts the frames to YIC color space applies
% motion magnification and writes the output video.
%
% Input:
%   filein              Input video file
%   fileout             Output file name
%   alpha               see lpiir.m
%   lambdaC             see lpiir.m
%   lowCutoff           see lpiir.m
%   highCutoff          see lpiir.m
%   chromAtt            see lpiir.m
%   exaggerationFactor  see lpiir.m
%   maxframes           Maximum number of frames to be used or 0 if all

% Open video reader
vidIn = VideoReader(filein);
startIndex = 1;

% Set endIndex
if (maxframes > 0)
    endIndex = maxframes;
else
    endIndex = vidIn.NumberOfFrames;
end

% Video file properties
nChannels = 3;
temp = struct('cdata', ...
		  zeros(vidIn.Height, vidIn.Width, nChannels, 'uint8'), ...
		  'colormap', []);

% Frame storage
frames = zeros(vidIn.Height, vidIn.Width, nChannels, endIndex);

% Read and show first frame
temp.cdata = read(vidIn, 1);
[rgbframe,~] = frame2im(temp);
imshow(rgbframe)

% Get rectangular area for motion magnification
rect = uint16(getrect);
disp('Reading file...');
% Read and convert all frames to YIC color space
for i=startIndex:endIndex
    % Read frame
    temp.cdata = read(vidIn, i);
    [rgbframe,~] = frame2im(temp);
    rgbframe = im2double(rgbframe);
    % Convert to YIC
    frame = rgb2ntsc(rgbframe);
    frames(:,:,:,i) = frame;
end
disp('Done reading file');
disp('Start processing: ');
%% Apply eulerian motion magnification
% with temporal IIR filter and spatial Laplacian pyramid
% on the user-defined magnification area

magnifyArea = frames(rect(2): rect(2)+rect(4),rect(1):rect(1)+rect(3),:,:);
framesOut = lpiir(magnifyArea, alpha, lambdaC, lowCutoff, highCutoff, chromAtt, exaggerationFactor);

%% Write output
disp('Writing to outputfile: ');

vidOut = VideoWriter(fileout);%, 'MPEG-4');
vidOut.FrameRate = vidIn.FrameRate;

open(vidOut)

% Convert each frame back to RGB and write to file
for i=startIndex:endIndex
    % Convert YIC to RGB color space
    rgbframe = ntsc2rgb(framesOut(:,:,:,i));
    progmeter(i,endIndex);
    % Clamp values to [0,1]
    rgbframe(rgbframe < 0) = 0;
    rgbframe(rgbframe > 1) = 1;
    % Add magnification area output back to whole frame
    fr = ntsc2rgb(frames(:,:,:,i));
    fr(rect(2): rect(2)+rect(4),rect(1):rect(1)+rect(3),:)=rgbframe;
    rgbframe = fr;
    writeVideo(vidOut, rgbframe);
end
close(vidOut);
disp('wrote video file');
close all;

end