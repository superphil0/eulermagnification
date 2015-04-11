function [ framesOut ] = lpiir( framesIn, alpha, lambdaC, lowCutoff, highCutoff )
%LPIIR
% Spatial Filtering: Laplacian pyramid
% Temporal Filtering: substraction of two IIR lowpass filters
%
numFrames = size(framesIn,4);
framesOut = zeros(size(framesIn));
% initial Frame prepare for IIR
for j = 1:3
    % spatial filtering
    [pyramid(:,:,j), sizes] = buildPyramid(framesIn(:,:,j,1));
end
lowpass1 = pyramid;
lowpass2 = pyramid;

for i = 2:numFrames
    progmeter(i,numFrames);
    
    for j = 1:3
        % spatial filtering
        [pyramid(:,:,j), sizes] = buildPyramid(framesIn(:,:,j,i));
    end
    
    % temporal filtering wit IIR filter
    lowpass1 = (1-lowCutoff) * lowpass1 + lowCutoff * pyramid;
    lowpass2 = (1-highCutoff) * lowpass2 + highCutoff * pyramid;
    filtered = lowpass1 - lowpass2;
    % see formula 14 in paper please explain george
    motion = lambdaC/8/(1+alpha);
    % also
    lambda = (sizes(1,1)^2 + sizes(2,1)^2).^0.5/3;
    ypositions = cumsum([1, sizes(1,:)]);
    % iterate through levels and amplify
    pyramidLevels = size(sizes,2);
    for j = 1:pyramidLevels
        % compute modified alpha for this level
        currAlpha = lambda/motion/8 - 1;
        % indices of current pyramid level
        if i < 2 || i > 7
            continue
        end
        if (currAlpha > alpha)  % representative lambda exceeds lambda_c
            filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:) = alpha*filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:);
        else
            filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:) = currAlpha*filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:);
        end
    end
    frame = zeros(size(framesIn(:,:,:,i)));

    frame(:,:,1) = reconstructPyramid(filtered(:,:,1),sizes);
    frame(:,:,2) = reconstructPyramid(filtered(:,:,2),sizes);
    frame(:,:,3) = reconstructPyramid(filtered(:,:,3),sizes);
    
    framesOut(:,:,:,i) = frame;    
end


