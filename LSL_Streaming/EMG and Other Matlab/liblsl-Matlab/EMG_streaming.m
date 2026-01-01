%
% Adapted from noraxon_stream example
% Author: Kieran Nichols
% -------------------------------------------------------------------------
addpath 'C:\Users\jeeva\OneDrive - UW-Madison\Training\LSL\EMG and Other Matlab\liblsl-Matlab';
addpath 'C:\Users\jeeva\OneDrive - UW-Madison\Training\LSL\EMG and Other Matlab\liblsl-Matlab\bin'
addpath 'C:\Users\jeeva\OneDrive - UW-Madison\Training\LSL\EMG_http'

% Open stream on (ip_address, port).   a popup will allow you to select one or more available
% channels to stream.
stream_config = noraxon_stream_init('127.0.0.1', 9220);

% collect 5 seconds of data, passing stream_config 
data = noraxon_stream_collect(stream_config, 1); 

%% instantiate the library
disp('Loading library...');
lib = lsl_loadlib();

% make a new stream outlet
disp('Creating a new streaminfo...');
len_channels = length(data);
info = lsl_streaminfo(lib,'EMG','EMG',len_channels,2000,'cf_float32','sdfwerr32432');

disp('Opening an outlet...');
outlet = lsl_outlet(info);

% send data into the outlet, sample by sample
disp('Now transmitting data...');

tic;

while true
    % test to see if we can do 0.01 sec or smaller, OR should we keep the sampling freq low (1 Hz)
    time = 1;
    data = noraxon_stream_collect(stream_config, time);
    len = length(data(1).samples); 
    tstart = toc;

    % Assuming data is a structure array and each data(i).samples is a fixed-length row vector
    num_samples = length(data(1).samples); % Determine the length of the samples
    chunk = zeros(num_samples, length(data)); % Preallocate a numerical array with appropriate size
    
    for i = 1:length(data)
        chunk(:, i) = data(i).samples'; % Transpose the samples and store in chunk
    end

    outlet.push_chunk(chunk)
    tend = toc;
    elapsed_time = tend-tstart;
    pause(time-elapsed_time)
    display(toc - tstart)

end
