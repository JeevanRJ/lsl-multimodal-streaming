%
% noraxon_stream example
%
% (c)2016 Noraxon USA, Inc.
%
% noraxon_stream requires Matlab R2014b or higher
% -------------------------------------------------------------------------
addpath 'C:\Users\jayasuriyaar\OneDrive - UW-Madison\Training\LSL\EMG and Other Matlab\liblsl-Matlab';
addpath 'C:\Users\jayasuriyaar\OneDrive - UW-Madison\Training\LSL\EMG and Other Matlab\liblsl-Matlab\bin'
addpath 'C:\Users\jayasuriyaar\OneDrive - UW-Madison\Training\LSL\EMG_http'
% setenv CUDA_VISIBLE_DEVICES -1

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
len_channels = length(data);%+1; % +1 for timestamp
info = lsl_streaminfo(lib,'EMG','EMG',len_channels,2000,'cf_float32','sdfwerr32432');

disp('Opening an outlet...');
outlet = lsl_outlet(info);

% send data into the outlet, sample by sample
disp('Now transmitting data...');

tic;

while true
    % test to see if we can do 0.01 sec or smaller, OR should we keep the sampling freq low (1 Hz)
    % do we need the pause function?
    time = 1;
    data = noraxon_stream_collect(stream_config, time);
    len = length(data(1).samples); % need to figure out if I iterate on all items of data
    % tstart = tic;
    tstart = toc;
    % need 
    % Assuming data is a structure array and each data(i).samples is a fixed-length row vector
    num_samples = length(data(1).samples); % Determine the length of the samples
    chunk = zeros(num_samples, len_channels); % Preallocate a numerical array with appropriate size
    
    for i = 1:len_channels
%         if i < len_channels-1
            chunk(:, i) = data(i).samples'; % Transpose the samples and store in chunk
%         else
%             chunk(:, i) = posixtime(datetime('now'));
%         end
    end
%     chunk = [data(1).samples'; data(2).samples'; data(3).samples'];
    % for i = 1:len_channels
    % 
    %     % for j = 1:len
    %     %     outlet.push_sample(data(i).samples(j));
    %     % end
    %     % outlet.push_sample(data(i).samples);
    %     % pause(0.01)
    % 
    % end
    % for i = 1:1%len_channels
    outlet.push_chunk(chunk')
    % end
    tend = toc;
    elapsed_time = tend-tstart;
    pause(time-elapsed_time)
    display(toc - tstart)
    % if toc - tic >= 1
    % pause(time);
    % toc

    % time_elapsed = end1 - start1
end

%%
% % Add paths to the LSL library
% addpath('C:\Users\the1k\source\repos\LSL_NASA\liblsl-Matlab-1.14.0-Win_amd64_R2020b\liblsl-Matlab');
% addpath('C:\Users\the1k\source\repos\LSL_NASA\liblsl-Matlab-1.14.0-Win_amd64_R2020b\liblsl-Matlab\bin');
% 
% % Load the LSL library
% stream_config = noraxon_stream_init('127.0.0.1', 9222);
% disp('Loading LSL library...');
% lib = lsl_loadlib();
% 
% % Create a new stream info
% disp('Creating a new streaminfo...');
% info = lsl_streaminfo(lib, 'TestStream', 'EEG', 1, 2000, 'cf_float32', 'testid');
% 
% % Open an outlet
% disp('Opening an outlet...');
% outlet = lsl_outlet(info);
% randn(10000, 10000)
% 
% % Send a sample
% disp('Now transmitting data...');
% while true
%     % data = noraxon_stream_collect(stream_config, time);
%     outlet.push_sample(randn(10000, 10000));
%     pause(1);
%     disp('Data transmission completed.');
% end
% 
% 
