
%% Specify the parameters
filein = 'wrist.mp4';   % Input file
fileout = 'out';        % Output file
alpha = 200;             % Amplification factor
lowCutoff = 1.2;        % Temporal frequency low cutoff
highCutoff = 0.4;      % Temporal frequency high cutoff
lambdaC = 16;           % Spatial frequency cutoff
chromAtt = 0.1;         % Chromattic Attenuation
exaggerationFactor = 140; % Motion exaggeration factor
maxframes = 0;          % Maximum number of frames used from the video

%% Perform Eulerian motion magnification
eulermag ( filein, fileout, alpha, lambdaC, lowCutoff, highCutoff, ...
    chromAtt, exaggerationFactor, maxframes);