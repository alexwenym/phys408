%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up translation stage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all;

%% Initialize the controller and the translation stage

% Motor serial number (specific to each station)
motorSN=63001449;

% Start system
myController=actxcontrol('MG17SYSTEM.MG17SystemCtrl.1', [0 0 100 100]);
myController.StartCtrl;

% Start motor
myStage=actxcontrol('MGMOTOR.MGMotorCtrl.1',[0,0,300,300]);
myStage.HWSerialNum = motorSN; 
myStage.StartCtrl;

% Hide the control panel out of the way
%set(gcf,'Visible','off');

motor_id = 0;
pause(2.0);

%% Get current position and current speed setting

% Position in [mm]

% Speed in [mm/s]
[status, min_v, accel, currentSpeed] = myStage.GetVelParams(motor_id, 0,0,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the scope 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a VISA-USB object.
interfaceObj = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x0699::0x0363::C107516::0::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(interfaceObj)
    interfaceObj = visa('TEK', 'USB0::0x0699::0x0363::C107516::0::INSTR');
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end

% Create a device object. 
deviceObj = icdevice('tektronix_tds2000B.mdd', interfaceObj);

% Connect device object to hardware.
connect(deviceObj);

%% Configure the scope

timeBase=5e-6;  % time scale in seconds (per division)

% Configure property value(s).
set(deviceObj.Acquisition(1), 'Timebase', timeBase);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Do the measurement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_dist = 3.0; % in mm 
move_increment = 0.10; % in mm 
move_steps = floor(move_dist/move_increment);

knifepos = []; 
voltages = [];

for i = 1:move_steps
    
    % move the shit
    newSpeed=0.1;  % in [mm/s]
    myStage.SetVelParams(motor_id, min_v, accel, newSpeed);
    
    currentPosition=myStage.GetPosition_Position(motor_id);

    newPosition=currentPosition+move_increment; % in [mm]
    myStage.SetAbsMovePos(motor_id, newPosition); 
    myStage.MoveAbsolute(motor_id, false);

    timeToWait = round(abs(newPosition-currentPosition)/newSpeed);
    pause(timeToWait + 1.0);
    timeToWait
    
    tekChannel=2;  % channel number for the readout

    % measure
    groupObj = get(deviceObj, 'Waveform');
    [Y,X,YUNIT,XUNIT] = invoke(groupObj, 'readwaveform', ['channel' num2str(tekChannel)]);
    
    mean_voltage = mean(Y);
    
    knifepos = [knifepos newPosition];
    voltages = [voltages mean_voltage];
end

save('knife_edge_data_ryan.mat','knifepos','voltages');

%% Disconnect and Clean Up
delete([deviceObj interfaceObj]);
clear groupObj;
clear deviceObj;
clear interfaceObj;

%% Clean up hardware objects
myController.StopCtrl;
myStage.StopCtrl;
clear myStage myController;
close(1);

