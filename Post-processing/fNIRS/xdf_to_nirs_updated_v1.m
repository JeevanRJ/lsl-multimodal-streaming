%
% Author: Kieran Nichols
% -------------------------------------------------------------------------

% Add XDF toolbox to path
% addpath('C:\Users\the1k\Documents\CurrentStudy\Fixed_Arrav\');
% addpath('C:\Users\jayasuriyaar\OneDrive - UW-Madison\Training\LSL\xdf-Matlab-master\xdf-Matlab-master\')
clear all; clc;
% Load the XDF file
xdf_file_path = 'ObstacleWalk_NoGVS.xdf';% Add XDF toolbox to path
[streams, fileheader] = load_xdf(xdf_file_path);

% Extract from previous .nirs file
% prev_data = load("C:\Users\the1k\Documents\NIRx\Data\2024-05-31\2024-05-31_004\2024-05-31_004.nirs", "-mat");
aurora_data = load("2024-07-02_001.nirs", "-mat");
% curr_data = load('C:\Users\the1k\source\repos\LSL_NASA\fNIRS\output_data.nirs', "-mat");

% Display available streams
% for i = 1:length(streams)
%     fprintf('Stream %d: %s\n', i, streams{i}.info.name{1});
% end

for i = 1:length(streams)
    if strcmp(streams{i}.info.name, 'Aurora')
        channel_num = i;
        % disp(['Aurora channel found, it is channel ', i]);
    end
    if strcmp(streams{i}.info.name, 'Aurora_accelerometer')
        accel_chann_num = i;
        % disp(['Aurora_accelerometer channel found, it is channel ', i]);
    end
end
% Extract the fNIRS data (assuming it's in the first stream)
fnirs_stream = streams{channel_num};  % Adjust index based on your file
fnirs_accel_stream = streams{accel_chann_num};
lsl_data = fnirs_stream.time_series;
fnirs_timestamps = fnirs_stream.time_stamps;

% Extract metadata from the fNIRS stream for SD structure
fnirs_info = fnirs_stream.info;

% Extract source positions, detector positions, and wavelengths from metadata
% SD = struct();
SD = aurora_data.SD;

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
aux_data = fnirs_accel_stream;
sizemn = size(aux_data.time_series);
downsampled_len = fnirs_len;  % Calculate the downsampled length

% Initialize the downsampled matrix with zeros
fnirs_accel_sampling_rate = fnirs_accel_stream.info.effective_srate/2; % for one accelerometer
fnirs_sampling_rate = fnirs_info.effective_srate;
accel_len = sizemn(2);
factor = ceil(sizemn(2)/fnirs_accel_sampling_rate*fnirs_sampling_rate);% 27, 26.1138;
reduction_factor = 4*3; %accel_len/factor;
% aux_data_down = zeros(reduction_factor,downsampled_len);

aux_1_length = length(streams{1, 2}.time_series(1,:));
% aux_data_1_flat = zeros(12,aux_1_length);
numOnes = sum(aux_data.time_series(1,:) == 1);
numTwos = sum(aux_data.time_series(1,:) == 2);

% Plot individual sets of data from each IMU sensor (accel, gyro, mag)
% figure; plot(squeeze(aurora_data.aux(:,1,:))); % accel1
% figure; plot(squeeze(aurora_data.aux(:,2,:))); % gyro1
% figure; plot(squeeze(aurora_data.aux(:,3,:))); % accel2
% figure; plot(squeeze(aurora_data.aux(:,4,:))); % gyro2

%% Test
aux_data_ones = [];
aux_data_twos = [];
itr = 1;
itr2 = 1;
sort_len = round(min(numOnes, numTwos)/fnirs_len)*fnirs_len; % it needs to be divisible by fnirs_len
pick1 = 3:5;
pick2 = 6:8;
pick_len = length(pick1);

for j = 1:aux_1_length %fnirs_len*12
    if aux_data.time_series(1,j) == 1 && itr2 < sort_len %itr <= 12*fnirs_len
        aux_data_ones(itr2,1:3) = aux_data.time_series(pick1,j)';
        aux_data_ones(itr2,7:9) = aux_data.time_series(pick2,j)';
        itr2 = itr2 + 1;
    end
    if aux_data.time_series(1,j) == 2 && itr < sort_len        
        aux_data_ones(itr,4:6) = aux_data.time_series(pick1,j)'; 
        aux_data_ones(itr,10:12) = aux_data.time_series(pick2,j)';
        itr = itr + 1;
    end
    % itr = itr + 1;
end
% end

% Downsample each column of aux_data.time_series
aux_data_down = zeros(fnirs_len,12);
for i = 1:sizemn(1)
    aux_data_down(:,i) = downsample(aux_data_ones(:,i), floor(sort_len/fnirs_len));
end

% aux_data_reshaped = zeros(fnirs_len,4,3);

% Ensure the downsampled matrix has the correct number of elements
% total_elements = numel(aux_data_down);
% aux_data_reshaped = reshape(aux_data_down, [fnirs_len, 4, 3]);

aux_data_reshape = zeros(fnirs_len,4,3); % time pts, device (accel 1, accel 2, gyro 1, gyro 2), metric (x,y,z)
% reshaping might not be the best approach; need to check
itr_arr = [1,3,2,4,5,7,6,8,9,11,10,12];
for i = 1:4
    for j = 1:3
        % itr = i*3 + j - 3;
        % itr = i + 3*j - 3;
        itr = itr_arr(i);
        item = aux_data_down(:,itr);
        aux_data_reshape(:,i,j) = reshape(item,[fnirs_len, 1, 1]);
    end
end
disp('Reshape successful.');

% Plot z,y,z for the accel (not sure if the x and y are switched but it shouldn't matter for data processing)
% plot(squeeze(aurora_data.aux(209-176:end,1,1))); hold on; plot(squeeze(lsl_data_raw.aux(:,1,1)));hold off;
% plot(squeeze(aurora_data.aux(209-176:end,4,1))); hold on; plot(squeeze(lsl_data_raw.aux(:,4,1))); hold off;
% plot(squeeze(aurora_data.aux(209-176:end,4,3))); hold on; plot(squeeze(lsl_data_raw.aux(:,4,3))); hold off;

% Create the .nirs file structure
% nirs_data = struct();
% fnirs = lsl_data(2:105,:);
% nirs_data.d = fnirs';
% nirs_data.t = fnirs_timestamps';
% nirs_data.SD = SD;
% nirs_data.s = s;
% nirs_data.aux = []; %aux_data_reshaped; 
fnirs = double(lsl_data(2:105,:));
d = fnirs';
t = fnirs_timestamps';
SD = SD;
s = s;
aux = aux_data_reshape; 
nirs_data = struct('t', t, 'd', d, 'SD', SD, 's', s, 'aux', aux);

% Save the .nirs file
output_file_name = 'output_data09_1.nirs';
save(output_file_name, '-struct', 'nirs_data');
disp(['File saved as ', output_file_name, ' in this directory:  ']);
disp(pwd);

