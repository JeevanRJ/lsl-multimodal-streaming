clc
clear all
load_xdf('test5.xdf')
targetNames = {'TimestampStream'}; % Replace with your actual target names
dataCellArray = ans;

% Iterate through each target name
for j = 1:length(targetNames)
    targetName = targetNames{j};

    % Initialize variables to hold time_series and time_stamps
    time_series = [];
    time_stamps = [];

    % Iterate through each cell in the cell array
    for i = 1:length(dataCellArray)
        % Access the struct within the current cell
        currentStruct = dataCellArray{i};

        % Check if the 'info' field exists in the current struct
        if isfield(currentStruct, 'info')
            % Access the 'info' struct
            infoStruct = currentStruct.info;

            % Check if the 'name' field exists in the 'info' struct
            if isfield(infoStruct, 'name')
                % Check if the 'name' field matches the target name
                if strcmp(infoStruct.name, targetName)
                    % If a match is found, load the time_series and time_stamps
                    time_series = currentStruct.time_series;
                    time_stamps = currentStruct.time_stamps;
                    break; % Exit the loop once the match is found
                end
            end
        end
    end

    % Dynamically create variable names based on the target name
    time_series_var_name = [targetName, '_time_series'];
    time_stamps_var_name = [targetName, '_time_stamps'];

    % Assign the variables in the base workspace
    assignin('base', time_series_var_name, time_series);
    assignin('base', time_stamps_var_name, time_stamps);
end

time_stamps = TimestampStream_time_series(1, :);


% If time_stamps is a cell array, convert it to a numeric array
if iscell(time_stamps)
    time_stamps = cellfun(@str2double, time_stamps);
end

% Convert milliseconds to seconds
time_stamps_seconds = time_stamps / 1000;

% Convert to datetime objects with local timezone
datetime_values = datetime(time_stamps_seconds, 'ConvertFrom', 'posixtime', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS', 'TimeZone', 'local');

% Display the datetime values
disp('Human-readable datetime values (local timezone):');
disp(datetime_values);