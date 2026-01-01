# README

This README file provides instructions and details for running the MATLAB code to process and analyze fNIRS data from an XDF file and save the results in a .nirs file format. The code is authored by Kieran Nichols.

## Prerequisites

1. **MATLAB**: Ensure you have MATLAB installed on your machine.
2. **XDF Toolbox**: You need to have the XDF Toolbox added to your MATLAB path. Modify the `addpath` statements to reflect the correct path on your system.
3. **Input Files**:
   - XDF file: `ObstacleWalk_NoGVS.xdf`
   - NIRS file: `2024-07-02_001.nirs`

## Instructions

### Step 1: Setup Environment

1. Add the XDF Toolbox to your MATLAB path by uncommenting and updating the following lines:
    ```matlab
    addpath('C:\Path\To\XDF_Toolbox');
    ```

### Step 2: Load the XDF File

1. Load the XDF file using the `load_xdf` function:
    ```matlab
    xdf_file_path = 'ObstacleWalk_NoGVS.xdf';
    [streams, fileheader] = load_xdf(xdf_file_path);
    ```

### Step 3: Load Aurora Data

1. Load the NIRS file containing Aurora data:
    ```matlab
    aurora_data = load('2024-07-02_001.nirs', '-mat');
    ```

### Step 4: Identify Relevant Streams

1. Identify the fNIRS and accelerometer streams:
    ```matlab
    for i = 1:length(streams)
        if strcmp(streams{i}.info.name, 'Aurora')
            channel_num = i;
        end
        if strcmp(streams{i}.info.name, 'Aurora_accelerometer')
            accel_chann_num = i;
        end
    end
    ```

### Step 5: Extract and Downsample Data

1. Extract and downsample the accelerometer data:
    ```matlab
    aux_data = streams{accel_chann_num};
    sizemn = size(aux_data.time_series);
    downsampled_len = length(fnirs_stream.time_stamps);
    fnirs_accel_sampling_rate = fnirs_accel_stream.info.effective_srate / 2;
    fnirs_sampling_rate = fnirs_info.effective_srate;
    factor = ceil(sizemn(2) / fnirs_accel_sampling_rate * fnirs_sampling_rate);
    reduction_factor = 4 * 3;
    ```

2. Sort and downsample accelerometer data:
    ```matlab
    % Code to sort and downsample accelerometer data...
    ```

### Step 6: Reshape Data

1. Reshape the downsampled data:
    ```matlab
    aux_data_reshape = zeros(downsampled_len, 4, 3);
    % Code to reshape data...
    ```

### Step 7: Save the Processed Data

1. Create the .nirs file structure and save it:
    ```matlab
    fnirs = double(lsl_data(2:105,:));
    d = fnirs';
    t = fnirs_timestamps';
    SD = aurora_data.SD;
    s = zeros(fnirs_len, 1);
    aux = aux_data_reshape;
    nirs_data = struct('t', t, 'd', d, 'SD', SD, 's', s, 'aux', aux);
    output_file_name = 'output_data09_1.nirs';
    save(output_file_name, '-struct', 'nirs_data');
    disp(['File saved as ', output_file_name, ' in this directory:  ']);
    disp(pwd);
    ```

## Notes

- Ensure that the paths to the XDF Toolbox and data files are correctly set.
- The provided code includes additional commented sections for displaying streams and plotting data for debugging purposes.
- Adjust any parameters or indices as necessary based on your specific data and experiment setup.

## Author

Kieran Nichols
