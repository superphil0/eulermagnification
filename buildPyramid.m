function [ levels, sizes ] = buildPyramid( image  )
%BUILDPYRAMID 
%   Laplacian Pyramid with bionomial filter and size 5
    kernel = [1 4 6 4 1]' * [1 4 6 4 1];
    kernel = kernel/ sum(sum(kernel));


    currentG = image; %assume image is of type double
    % filter and downsample
    nextG =  imresize(imfilter(currentG, kernel, 'replicate'),0.5,'nearest');
    % upsample and subtract
    currentL = currentG - imresize(nextG, size(currentG),'method','nearest');
     currentG = nextG;
    levels = currentL;
  
    sizes(:,1) = size(image);
    sizes(:,2) = size(nextG);
    
    levelindex = 2;

    while 1
        
        %in last level store only gaussian
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

