clc;
clear all;

% Load the .xdf file
dataCellArray = load_xdf('sample.xdf'); % Assuming this function returns the 1x29 cell array

% Define the target names by category
xsensTargets = {'CenterOfMass1', 'QuaternionDatagram1', 'EulerDatagram1', 'AngularKinematics1', 'LinearSegmentKinematicsDatagram1', 'TrackerKinematicsDatagram1'};
fnirsTargets = {'Aurora', 'Aurora_accelerometer'};
emgTargets = {'EMG'};
tobiiTargets = {'GazeOrigin', 'Pupil', 'GazeDirection'};
otherTargets = {'Gyroscope', 'Accelerometer', 'Gaze3d', 'Gaze2d', 'Magnetometer'};

% Combine all target names
allTargetNames = [xsensTargets, fnirsTargets, emgTargets, tobiiTargets, otherTargets];

% Initialize a flag to check if all data is okay
allDataOkay = true;
foundNames = {}; % To keep track of found target names

% Initialize missingVars fields to be empty cell arrays
missingVars.Xsens = {};
missingVars.fNIRS = {};
missingVars.EMG = {};
missingVars.Tobii = {};

% Iterate through each cell in dataCellArray
for i = 1:length(dataCellArray)
    % Get the current struct
    currentStruct = dataCellArray{i};
    
    % Check if 'info', 'time_series', and 'time_stamps' fields are present
    if isfield(currentStruct, 'info') && isfield(currentStruct, 'time_series') && isfield(currentStruct, 'time_stamps')
        % Check if 'info' contains the 'name' field
        if isfield(currentStruct.info, 'name')
            % Get the name
            name = currentStruct.info.name;
            
            % Check if the name is in the allTargetNames list
            if ismember(name, allTargetNames)
                % Add the name to the found names list
                foundNames{end+1} = name;
                
                % Check for missing data in 'time_series' and 'time_stamps'
                if isempty(currentStruct.time_series) || isempty(currentStruct.time_stamps)
                    allDataOkay = false;
                    if ismember(name, xsensTargets)
                        missingVars.Xsens{end+1} = name;
                    elseif ismember(name, fnirsTargets)
                        missingVars.fNIRS{end+1} = name;
                    elseif ismember(name, emgTargets)
                        missingVars.EMG{end+1} = name;
                    elseif ismember(name, tobiiTargets)
                        missingVars.Tobii{end+1} = name;
                    end
                end
            end
        end
    else
        % If the necessary fields are not present
        allDataOkay = false;
    end
end

% Check for any target names that were not found
missingNames = setdiff(allTargetNames, foundNames);
for i = 1:length(missingNames)
    name = missingNames{i};
    if ismember(name, xsensTargets)
        missingVars.Xsens{end+1} = name;
    elseif ismember(name, fnirsTargets)
        missingVars.fNIRS{end+1} = name;
    elseif ismember(name, emgTargets)
        missingVars.EMG{end+1} = name;
    elseif ismember(name, tobiiTargets)
        missingVars.Tobii{end+1} = name;
    end
end

% Combine all missing variables into a single message
errorMessage = '';
if ~isempty(missingVars.Xsens)
    errorMessage = [errorMessage, 'Please check the Xsens data. Following variables are missing:', newline, sprintf('%s\n', missingVars.Xsens{:}), newline];
end
if ~isempty(missingVars.fNIRS)
    errorMessage = [errorMessage, 'Please check the fNIRS data. Following variables are missing:', newline, sprintf('%s\n', missingVars.fNIRS{:}), newline];
end
if ~isempty(missingVars.EMG)
    errorMessage = [errorMessage, 'Please check the EMG data. Following variables are missing:', newline, sprintf('%s\n', missingVars.EMG{:}), newline];
end
if ~isempty(missingVars.Tobii)
    errorMessage = [errorMessage, 'Please check the Tobii Glass 3 data. Following variables are missing:', newline, sprintf('%s\n', missingVars.Tobii{:}), newline];
end



% Display a popup message with the error information if there are missing variables
if ~isempty(errorMessage)
    msgbox(errorMessage, 'Data Missing', 'error');
    playBeep(1000, 0.3); % High frequency beep for error
else
    msgbox('All data okay', 'Data Status', 'help');
    playBeep(100, 0.2); % Low frequency beep for okay
end

% Function to play a customized beep sound
function playBeep(freq, duration)
    fs = 8192; % Sampling frequency
    t = 0:1/fs:duration;
    sound(sin(2*pi*freq*t), fs);
end
