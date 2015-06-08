function progmeter(i,n)
% Displays percentage of progression
% i     current step
% n     number of steps

if i==0    
    fwrite(1,sprintf('00%%'));
    return;
elseif ischar(i)
    fwrite(1,sprintf('%s\n',i));
    fwrite(1,sprintf('00%%'));
    return;
end

if mod(i,n/100) <= mod(i-1,n/100),
    fwrite(1,sprintf('\b\b\b'));
    fwrite(1,sprintf('%02d%%', round(100*i/n)));
end

if i==n,
  fprintf(1,'\n');
end
