% Rasperry Pi address (specific to each station)
piAddress='142.103.238.11';  

% Initialize
mypi = raspi(piAddress,'pi','raspberry'); 

%% Call python script "vsearch.py" for parking the monochromator on one of the strong spectral lines 
%  by searching for strong PMT signal in channel CH0.
%
% the -s value is the count to start at for looking for a voltage on CH0
% the -e value is the count to stop looking for a voltage on CH0
% the range of counts is from 0 to 12000
% the -k value is the voltage in mV that is being searched for on CH0

% NOTE: this -k value should be positive and an integer.  The code assumes 
% that CH0 will always be the PMT.  Since the PMT values are negative 
% the code takes the absolute value of the ADC recording to compare it to 
% the desired voltage set by the -k value.

% the motor will home first and then quickly go to the start position and
% then more slowly go from the specified start to end step count values.

% this command runs the vsearch.py code with user specifications
system(mypi,'python3 /home/pi/hene_code/vsearch.py -s 6200 -e 6400 -k 800')


%% Call pyhton script scanCH0CH1.py for scanning the monochromator while recording both the PMT and 
%  the Lock-in signals on channels CH0 and CH1, respectively.
%
% Description of scanCH0CH1.py code:
% Note: This code takes some time to home the stepper motor first.
% This code assumes the PMT is plugged into CH0 of the ADC
% and the lock in output is plugged into CH1 of the ADC
% This code homes the motor and collects data on CH0 and CH1.
% At every step (0 to 12000) the ADC collects a certain number of samples
% for each channel at a certain rate. 
% The default is 100 samples per channel at 12 kHz.
% The code only records the minimum value detected 
% for the samples taken on each channel for each step count.
% The file result.dat gets written to /home/pi and is three columns
% with 12000 rows.  The first column is the step count, 
% The second column is the CH0 recording of the PMT.
% The third colum is teh CH1 recording of the lockin.

% to specify a desired samples per channel use the -p option
% to specify a desired scan rate use the -c option
% please only input positive integers
% the -s value is the count to start at
% the -e value is the count to stop at

system(mypi,'python3 /home/pi/hene_code/scanCH0CH1opt.py -p 100 -c 12000 -s 600 -e 700');


%% Retrieve the data from RasPi 

% to get the 'result.dat' file use getFile as described in
%https://www.mathworks.com/help/supportpkg/raspberrypiio/ref/getfile.html
getFile(mypi,'result.dat');
% this assumes you have the file in /home/pi on the raspberry pi and
% you want to copy it to the current active folder on your computer
% that MATLAB is using.

% for analysis use standard MATLAB commands such as:
data = readmatrix('result.dat');

count = data(:,1);
pmt = data(:,2);
lockin = data(:,3);

%% Clean up hardware objects
clear mypi
