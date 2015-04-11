function [ image ] = reconstructPyramid( levels , sizes )
%RECONSTRUCTPYRAMID reverse
    
    ypositions = cumsum([1, sizes(1,:)]);
    
    n = size(sizes,2);
    
    prevGauss = levels(ypositions(n):end, 1:sizes(2,n)); 
    for i = n-1:-1:1;
        % expand       
        L = levels(ypositions(i):ypositions(i+1)-1, 1:sizes(2,i)); 
        gauss = imresize(prevGauss, size(L), 'nearest');
        prevGauss = L + gauss;
    end
    
    image = uint8(prevGauss);
end