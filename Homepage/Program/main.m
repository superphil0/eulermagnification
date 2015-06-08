
%% Specify the parameters
filein = 'wrist.mp4';   % Input file
fileout = 'out';        % Output file
alpha = 10;             % ?
lowCutoff = 0.4;        % Low cutoff
highCutoff = 0.05;      % High cutoff
lambdaC = 16;           % ?
chromAtt = 0.1;         % Chromattic Attenuation
exaggerationFactor = 8; % Motion exaggeration factor
maxframes = 0;          % Maximum number of frames used from the video

%% Perform Eulerian motion magnification
eulermag ( filein, fileout, alpha, lambdaC, lowCutoff, highCutoff, ...
    chromAtt, exaggerationFactor, maxframes);