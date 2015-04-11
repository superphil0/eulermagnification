function [ framesOut ] = lpiir( framesIn, alpha, lambdaC, lowCutoff, highCutoff )
%LPIIR 
% Spatial Filtering: Laplacian pyramid
% Temporal Filtering: substraction of two IIR lowpass filters
% 
numFrames = size(framesIn,4);

% initial Frame prepare for IIR 
for j = 1:3
    % spatial filtering
    pyramid(:,:,:,j) = buildPyramid(framesIn(:,:,j,1));
end 
lowpass1 = pyramid;
lowpass2 = pyramid;
pyramidLevels = size(pyramid,?)
for i = 2:numFrames
    

end

