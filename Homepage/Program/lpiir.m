function [ framesOut ] = lpiir( framesIn, alpha, lambdaC, lowCutoff, highCutoff, chromAtt,exagerationFactor )
% Apply Eulerian motion magnification using the following filters
% Spatial Filtering: Laplacian pyramid
% Temporal Filtering: IIR (Infinite Impulse Response) filter
% Two images are updated using the low and high cutoff parameters and
%  subtracted to filter the frame sequence according to these specified
%  frequency bands. I.e., bandpass filtering is achieved by subtracting 
%  two lowpass filters of different thresholds.
%
% The temporal filtering is applied to the whole Laplacian pyramid thereby
% magnifying signals in different spatial sizes.
%
% Input:
%   framesIn            frames of the input video (in YIC color space)
%   alpha               % Amplification factor
%   lambdaC             % Spatial frequency cutoff
%   lowCutoff           % Temporal frequency low cutoff
%   highCutoff          % Temporal frequency high cutoff
%   chromAtt            % Chromatic attentuation
%   exaggerationFactor  % Motion exaggeration factor
%
% Output:
%   framesOut           motion magnified frames

% Prepare output
numFrames = size(framesIn,4);
framesOut = zeros(size(framesIn));

% Prepare IIR filters using the first frame
for j = 1:3
    % spatial filtering
    [pyramid(:,:,j), sizes] = buildPyramid(framesIn(:,:,j,1));
end
lowpass1 = pyramid;
lowpass2 = pyramid;

% Apply filter on all consecutive frames
for i = 2:numFrames
    progmeter(i,numFrames);
    frameIn = framesIn(:,:,:,i);
    
    % spatial filtering (each color separately)
    for j = 1:3
        [pyramid(:,:,j), sizes] = buildPyramid(frameIn(:,:,j));
    end
    
    % temporal filtering with IIR filters
    lowpass1 = (1-lowCutoff) * lowpass1 + lowCutoff * pyramid; % low pass filter with low cutoff
    lowpass2 = (1-highCutoff) * lowpass2 + highCutoff * pyramid; % low pass filter with high cutoff
    filtered = lowpass1 - lowpass2; % bandpass filtered signal
    
    % term used in modifiyng alpha according to spatial frequencies
    % to avoid incorrectly amplfified motions (see Paper 
    delta = lambdaC/8/(1+alpha);
    
    % representative wavelength for the lowest spatial frequency band
    % (lowest pyramid level)
    lambda = (sizes(1,1)^2 + sizes(2,1)^2).^0.5/3;
    
    % iterate through levels and amplify motion
    pyramidLevels = size(sizes,2);
    ypositions = cumsum([1, sizes(1,:)]);
    for j = 1:pyramidLevels %bottom up
        % compute modified alpha for this level
        currAlpha = lambda/delta/8 - 1;
        currAlpha = currAlpha*exagerationFactor; %exaggerate motion for visualisation
        
        % do not apply to bottom or top levels
        if i < 2 || i > 7
            continue
        end
        if (currAlpha > alpha)
            filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:) = alpha*filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:);
        else % spatial frequency is beyond the lambdaC cutoff --> use attenuated alpha
            
            %if currAlpha < alpha %force alpha = 0 for human pulse visualisation
            %    currAlpha = 0;
            %end
            filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:) = currAlpha*filtered(ypositions(j):ypositions(j+1)-1, 1:sizes(2,j),:);
        end
        
        %half representative wavelength for half-sized next pyramid level
        lambda = lambda/2;
    end
    
    frameOut = zeros(size(frameIn));

    %reconstruct YIC image from the pyramid and apply chromatic attenuation
    %to chroma channels
    frameOut(:,:,1) = reconstructPyramid(filtered(:,:,1),sizes);
    frameOut(:,:,2) = reconstructPyramid(filtered(:,:,2),sizes) * chromAtt; %chrom. attenuation
    frameOut(:,:,3) = reconstructPyramid(filtered(:,:,3),sizes) * chromAtt; %chrom. attenuation
    
    % add amplified motion to input
    framesOut(:,:,:,i) = frameOut + frameIn;    
end


