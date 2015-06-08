function [ levels, sizes ] = buildPyramid( image  )
% Constructs a Laplacian Pyramid with a bionomial filter of size 5
% Builds up to 8 levels
%
% Input:
%  image     Input image of type double
% Output:
%  levels    Single image file with double the height including all the levels
%  sizes     Pixel sizes of each level

kernel = [1 4 6 4 1]' * [1 4 6 4 1];
kernel = kernel/ sum(sum(kernel));


% Prepare first level
currentG = image;
% filter and downsample
nextG =  imresize(imfilter(currentG, kernel, 'replicate'),0.5,'nearest');
% upsample and subtract
currentL = currentG - imresize(nextG, size(currentG),'method','nearest');
currentG = nextG;
levels = currentL;

sizes(:,1) = size(image);
sizes(:,2) = size(nextG);

levelindex = 2;

% Construct remaining levels until 8 levels or level of size 1 created
while 1
    %in last level store only the gaussian
    if (levelindex >= 8 || (max(size(currentG)) <= 1))
        currentG = zeros(size(nextG,1),size(image,2));
        currentG(1:size(nextG,1),1:size(nextG,2)) = nextG;
        
        
        levels = [levels; currentG];
        break;
    end
    
    % filter and downsample
    nextG =  imresize(imfilter(currentG, kernel, 'replicate'),0.5,'nearest');
    % upsample and subtract
    currentL = zeros(size(nextG,1),size(image,2));
    currentL(1:size(currentG,1),1:size(currentG,2)) = currentG - imresize(nextG, size(currentG),'nearest');
    
    sizes(:,levelindex+1) = size(nextG);
    levels = [levels; currentL];
    levelindex = levelindex + 1;
    
    % move to next level
    currentG = nextG;
end

end

