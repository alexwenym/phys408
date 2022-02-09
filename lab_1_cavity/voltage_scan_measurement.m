%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up translation stage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all;

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
groupObj = get(deviceObj, 'Waveform');
[Y_input,X_input,YUNIT_input,XUNIT_input] = invoke(groupObj, 'readwaveform', ['channel' num2str(1)]);
[Y_output,X_output,YUNIT_output,XUNIT_output] = invoke(groupObj, 'readwaveform', ['channel' num2str(2)]);


save('voltage_scan_data_Ldegenerate.mat','Y_input','X_input','YUNIT_input','XUNIT_input','Y_output','X_output','YUNIT_output','XUNIT_output');

%% Disconnect and Clean Up
delete([deviceObj interfaceObj]);
clear groupObj;
clear deviceObj;
clear interfaceObj;

