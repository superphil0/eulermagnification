function [ image ] = reconstructPyramid( levels , sizes )
% Reconstructs the image from the Laplacian pyramid
%
% Input:
%  levels    Laplacian pyramid image file
%  sizes     Pixel sizes of each level
% Output:
%  image     Reconstructed image

% Re-calculate level positions in the pyramid image
ypositions = cumsum([1, sizes(1,:)]);

n = size(sizes,2);

% Reconstruct the pyramid by expanding and adding
prevGauss = levels(ypositions(n):end, 1:sizes(2,n));
for i = n-1:-1:1;
    % expand
    L = levels(ypositions(i):ypositions(i+1)-1, 1:sizes(2,i));
    gauss = imresize(prevGauss, size(L), 'nearest');
    prevGauss = L + gauss;
end

image = prevGauss;
end