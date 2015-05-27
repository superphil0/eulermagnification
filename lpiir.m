function [ framesOut ] = lpiir( framesIn, alpha, lambdaC, lowCutoff, highCutoff, chromAtt,exagerationFactor )
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
    frameIn = framesIn(:,:,:,i);
    
    for j = 1:3
        % spatial filtering
        [pyramid(:,:,j), sizes] = buildPyramid(frameIn(:,:,j));
    end
    
    % temporal filtering wit IIR filter
    lowpass1 = (1-lowCutoff) * lowpass1 + lowCutoff * pyramid;
    lowpass2 = (1-highCutoff) * lowpass2 + highCutoff * pyramid;
    filtered = lowpass1 - lowpass2;
    
    % see formula 14 in paper please explain george
    delta = lambdaC/8/(1+alpha);
    
    % representative wavelength for the lowest spatial frequency band
    % (lowest pyramid level)
    lambda = (sizes(1,1)^2 + sizes(2,1)^2).^0.5/3;
    
    % iterate through levels and amplify
    pyramidLevels = size(sizes,2);
    ypositions = cumsum([1, sizes(1,:)]);
    for j = 1:pyramidLevels %bottom up
        % compute modified alpha for this level
        currAlpha = lambda/delta/8 - 1;
        currAlpha = currAlpha*exagerationFactor; %exaggerate for visualisation %TODO as param
        
        % indices of current pyramid level
        if i < 2 || i > 7
            continue
        end
        if (currAlpha > alpha)  % representative lambda exceeds lambdaC
            filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:) = alpha*filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:);
        else
            %if currAlpha < alpha %force alpha = 0 for human pulse visualisation TODO param
            %    currAlpha = 0;
            %end
            filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:) = currAlpha*filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:);
        end
        
        %half representative wavelength for half-sized next pyramid level
        lambda = lambda/2;
    end
    
    frameOut = zeros(size(frameIn));

    frameOut(:,:,1) = reconstructPyramid(filtered(:,:,1),sizes);
    frameOut(:,:,2) = reconstructPyramid(filtered(:,:,2),sizes) * chromAtt; %chrom. attenuation
    frameOut(:,:,3) = reconstructPyramid(filtered(:,:,3),sizes) * chromAtt; %chrom. attenuation
    
    %sum(sum(sum(frameOut)))
    
    % add amplified motion to input
    framesOut(:,:,:,i) = frameOut*2 + frameIn;    
end


