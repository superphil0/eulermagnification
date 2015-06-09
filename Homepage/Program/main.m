
%% Specify the parameters
filein = 'guitar.mp4';   % Input file
fileout = 'out';        % Output file
alpha = 80;             % Amplification factor
lowCutoff = 0.1;        % Temporal frequency low cutoff
highCutoff = 0.01;      % Temporal frequency high cutoff
lambdaC = 16;           % Spatial frequency cutoff
chromAtt = 0.1;         % Chromattic Attenuation
exaggerationFactor = 22; % Motion exaggeration factor
maxframes = 0;          % Maximum number of frames used from the video

%% Perform Eulerian motion magnification
eulermag ( filein, fileout, alpha, lambdaC, lowCutoff, highCutoff, ...
    chromAtt, exaggerationFactor, maxframes);