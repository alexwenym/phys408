%% An example script for communicating with a Tektronix Scope
% 
% Refer to "getting_started_using_matlab_with_tektronix_over_gpib.pdf" for details.


%% Connect to the scope

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


%% Download and plot data from the scope

tekChannel=2;  % channel number for the readout

% Execute device object function(s).
groupObj = get(deviceObj, 'Waveform');
[Y,X,YUNIT,XUNIT] = invoke(groupObj, 'readwaveform', ['channel' num2str(tekChannel)]);

figure;
plot(X,Y);

%% Disconnect and Clean Up
delete([deviceObj interfaceObj]);
clear groupObj;
clear deviceObj;
clear interfaceObj;

