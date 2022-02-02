%% An example script for communicating with a Raspberry Pi camera
%
% IMPORTANT: 
%   1. If you used a web interface to watch the rasPi camera in real time, 
%   make sure you stopped the camera in that interface (press "Stop Camera").
%
%   2. If neither the web interface nor Matlab can communicate with the camera (freeze), use MobaXTerm:
%   >> ssh pi@142.103.238.17 (change address accordingly, password = raspberry)
%   >> sudo reboot now

clear all; close all;

%% Initialize the camera
clear mypi mycam;    % in case it wasn't cleaned up after last use

% Rasperry Pi address (specific to each station)
piAddress='142.103.238.21';    

% Useful parameters (use ">>help cameraboard" to see available parameters)
frameRate=30;       % rate of recording a movie in [frames/s]
imageAngle=0;       % degree of rotation in [deg]
imageResolution='640x480'; % resolution 

% Initialize
mypi = raspi(piAddress,'pi','raspberry'); 
mycam = cameraboard(mypi,'Resolution',imageResolution,...
                         'Rotation',imageAngle,...
                         'FrameRate',frameRate);     

%% Take a single image and plot it

% Clear the buffer by taking 5 pre-shots
for k=1:5; snapshot(mycam); end;

% Take the final image
colorImage = snapshot(mycam);
bwImage = rgb2gray(colorImage);  % convert to gray scale

% Plot the image
figure;
imagesc(bwImage);
colormap gray;

save('CCD_image.mat','bwImage');

%% Clean up hardware objects
clear mycam mypi