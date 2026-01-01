%
% noraxon_stream example
%
% (c)2016 Noraxon USA, Inc.
%
% noraxon_stream requires Matlab R2014b or higher
% -------------------------------------------------------------------------


% Open stream on (ip_address, port).   a popup will allow you to select one or more available
% channels to stream.
stream_config = noraxon_stream_init('127.0.0.1', 9220);

% collect 5 seconds of data, passing stream_config 
data = noraxon_stream_collect(stream_config, 1); 

