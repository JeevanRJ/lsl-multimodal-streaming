% Add XDF toolbox to path
% addpath('C:\Users\the1k\Documents\CurrentStudy\Fixed_Arrav\');
addpath('C:\Users\jayasuriyaar\OneDrive - UW-Madison\Training\LSL\xdf-Matlab-master\xdf-Matlab-master\')

% Load the XDF file
xdf_file_path = 'TestJune07.xdf';% Add XDF toolbox to path
[streams, fileheader] = load_xdf(xdf_file_path);

% Extract from previous .nirs file
% prev_data = load("C:\Users\the1k\Documents\NIRx\Data\2024-05-31\2024-05-31_004\2024-05-31_004.nirs", "-mat");
aurora_data = load("old\2024-06-07_003.nirs", "-mat");
% curr_data = load('C:\Users\the1k\source\repos\LSL_NASA\fNIRS\output_data.nirs', "-mat");

% Display available streams
% for i = 1:length(streams)
%     fprintf('Stream %d: %s\n', i, streams{i}.info.name{1});
% end

for i = 1:length(streams)
    if strcmp(streams{i}.info.name, 'Aurora')
        channel_num = i;
        disp(['Aurora channel found, it is channel ', i]);
    % else
    %     % disp('no Aurora');
    end
    if strcmp(streams{i}.info.name, 'Aurora_accelerometer')
        accel_chann_num = i;
        disp(['Aurora_accelerometer channel found, it is channel ', i]);
    % else
    %     % disp('no Aurora');
    end
end
% Extract the fNIRS data (assuming it's in the first stream)
fnirs_stream = streams{channel_num};  % Adjust index based on your file
fnirs_accel_stream = streams{accel_chann_num};
lsl_data = fnirs_stream.time_series;
fnirs_timestamps = fnirs_stream.time_stamps;
% channel 21 is NSP3 and 15 is Aurora accelerometer

% Extract metadata from the fNIRS stream for SD structure
fnirs_info = fnirs_stream.info;

% Extract source positions, detector positions, and wavelengths from metadata
% SD = struct();
SD = aurora_data.SD;
% SD.Lambda = prev_data.SD; %[760 850]; %str2double(strsplit(fnirs_info.desc.channels.channel{1,4}.wavelength));  % Example: '690 830'
% SD.SrcPos = str2double(strsplit(fnirs_info.desc.montage.optodes.sources.source.location));
% SD.DetPos = str2double(strsplit(fnirs_info.desc.channels.channel{1,4}.wavelength));

% Extract measurement list
% SD.MeasList = [];
% for ch = 1:length(fnirs_info.desc.channels.channel)
%     src_idx = str2double(fnirs_info.desc.channels.channel{ch}.properties.Property.lsl_channel_source_idx);
%     det_idx = str2double(fnirs_info.desc.channels.channel{ch}.properties.Property.lsl_channel_detector_idx);
%     lambda_idx = find(SD.Lambda == str2double(fnirs_info.desc.channels.channel{ch}.properties.Property.lsl_channel_wavelength));
%     SD.MeasList = [SD.MeasList; src_idx, det_idx, lambda_idx, 1];  % Assuming all measurements are active (status = 1)
% end

% % Extract stimulus markers (assuming it's in the second stream)
% stim_stream = streams{2};  % Adjust index based on your file
% stim_timestamps = stim_stream.time_stamps;
% stim_codes = stim_stream.time_series;

% % Create stimulus vector (s) % don't need for our experiments
fnirs_len = length(fnirs_timestamps);
s = zeros(fnirs_len, 1);
% for i = 1:length(stim_timestamps)
%     [~, idx] = min(abs(fnirs_timestamps - stim_timestamps(i)));
%     s(idx) = stim_codes(i);
% end

% Extract auxiliary data if available (assuming it's in the third stream)
% imu: (value by time step, sensor, x/y/z); sensors are accel, gyro, magn, hall resistance
% device_id, accelerometer_id, accel x,y,z; gyro x,y,z; magn x,y,z, hall resistence
% aux_data = [];
aux_data = fnirs_accel_stream;
% fnirs_len = 61;  % Define the length for downsampling
sizemn = size(aux_data.time_series);
downsampled_len = fnirs_len;  % Calculate the downsampled length

% Initialize the downsampled matrix with zeros
aux_data_down = zeros(sizemn(1),downsampled_len);

% Downsample each column of aux_data.time_series
for i = 1:sizemn(1)
    aux_data_down(i,:) = downsample(aux_data.time_series(i, :), 27)';
end

% Ensure the downsampled matrix has the correct number of elements
total_elements = numel(aux_data_down);
if total_elements == fnirs_len * 4 * 3
    % Reshape the matrix from downsampled_len x sizemn(2) to 61x4x3
    aux_data_reshaped = reshape(aux_data_down, [fnirs_len, 4, 3]);
    disp('Reshape successful.');
else
    error('Number of elements does not match for reshaping. Please check your downsampling or reshaping parameters.');
end


% Create the .nirs file structure
nirs_data = struct();
fnirs = lsl_data(2:105,:);
nirs_data.d = fnirs';
nirs_data.t = fnirs_timestamps';
nirs_data.SD = SD;
nirs_data.s = s;
% if ~isempty(aux_data)
% nirs_data.aux = aux_data;
nirs_data.aux = aux_data_reshaped; %aurora_data.aux(2:end,:,:);
% end

% Save the .nirs file
output_file_name = 'output_data1.nirs';
save(output_file_name, '-struct', 'nirs_data');
disp(['File saved as ', output_file_name, ' in this directory:  ']);
disp(pwd);

