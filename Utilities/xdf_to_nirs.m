%% xdf_to_nirs_from_aurora_template.m
% Convert XDF Aurora stream -> Homer .nirs (MAT struct)
% Uses a template .nirs to carry SD (and optionally aux structure).
% Optionally fills aux from Aurora_accelerometer via interpolation.

clear; clc;

%% ================== USER SETTINGS ==================
xdf_file_path       = 'TWEO_NOGVS_T1.xdf';
template_nirs_path  = '2024-06-21_001.nirs';
output_nirs_path    = 'TWEO_NOGVS_T1_fromXDF.nirs';

USE_XDF_ACCEL_AS_AUX = true;   % if false, keep template aux only
ACC_SENSOR_ID_PAIR   = [1 1];  % choose which accelerometer in Aurora_accelerometer (e.g., [1 1] or [2 2])

% Aurora stream: you are currently using rows 2:105
FNIRS_ROW_RANGE = 2:105;       % adjust if needed

% Interp settings
INTERP_METHOD = 'linear';
INTERP_EXTRAP = 'extrap';      % use 'extrap' to avoid NaNs at ends
%% ====================================================

% Load XDF
[streams, ~] = load_xdf(xdf_file_path);

% Find streams
aurora_idx = [];
accel_idx  = [];
for i = 1:numel(streams)
    if isfield(streams{i}, 'info') && isfield(streams{i}.info, 'name')
        nm = streams{i}.info.name;
        if strcmp(nm, 'Aurora')
            aurora_idx = i;
        elseif strcmp(nm, 'Aurora_accelerometer')
            accel_idx = i;
        end
    end
end

if isempty(aurora_idx)
    error('Aurora stream not found in XDF.');
end
if USE_XDF_ACCEL_AS_AUX && isempty(accel_idx)
    error('Aurora_accelerometer stream not found in XDF (but USE_XDF_ACCEL_AS_AUX=true).');
end

% Load template .nirs (provides SD + optionally aux template)
tmpl = load(template_nirs_path, '-mat');
if ~isfield(tmpl, 'SD')
    error('Template .nirs file does not contain SD structure.');
end

SD = tmpl.SD;

%% -------- Extract fNIRS from Aurora stream --------
fnirs_stream = streams{aurora_idx};
lsl_data = fnirs_stream.time_series;
t_fnirs  = fnirs_stream.time_stamps(:);
t_fnirs  = t_fnirs - t_fnirs(1);

% Safety: ensure requested rows exist
nRows = size(lsl_data, 1);
if max(FNIRS_ROW_RANGE) > nRows
    error('FNIRS_ROW_RANGE exceeds available rows in Aurora time_series (rows=%d).', nRows);
end

% Your convention: use rows 2:105 and transpose to NxCh
d = double(lsl_data(FNIRS_ROW_RANGE, :))';
t = double(t_fnirs);

% Stimulus vector (none)
s = zeros(numel(t), 1);

%% -------- Build aux --------
aux = [];
if isfield(tmpl, 'aux') && ~isempty(tmpl.aux)
    aux = tmpl.aux; % start from template
end

if USE_XDF_ACCEL_AS_AUX
    acc_stream = streams{accel_idx};
    both_acc = double(acc_stream.time_series);
    t_acc_all = double(acc_stream.time_stamps(:));
    t_acc_all = t_acc_all - t_acc_all(1);

    % Identify columns belonging to chosen sensor ID pair
    % Convention in your code: row1 and row2 store IDs (e.g., 1/1 or 2/2)
    idx_sensor = (both_acc(1,:) == ACC_SENSOR_ID_PAIR(1)) & (both_acc(2,:) == ACC_SENSOR_ID_PAIR(2));
    if ~any(idx_sensor)
        error('No accel samples found for sensor ID pair [%d %d].', ACC_SENSOR_ID_PAIR(1), ACC_SENSOR_ID_PAIR(2));
    end

    acc_sel = both_acc(:, idx_sensor);
    t_acc   = t_acc_all(find(idx_sensor)); %#ok<FNDSB> timestamps aligned with selected samples

    % Normalize selected timestamps to start at 0
    t_acc = t_acc - t_acc(1);

    % Extract channels (based on your layout)
    % rows: 3=X, 4=Y, 5=Z, 6=Gx, 7=Gy, 8=Gz
    accX  = acc_sel(3, :);
    accY  = acc_sel(4, :);
    accZ  = acc_sel(5, :);   % FIX: was wrong in your code 2 (you repeated 4)
    gyrX  = acc_sel(6, :);
    gyrY  = acc_sel(7, :);
    gyrZ  = acc_sel(8, :);

    % Interpolate to fNIRS time base
    accX_i = interp1(t_acc, accX, t, INTERP_METHOD, INTERP_EXTRAP);
    accY_i = interp1(t_acc, accY, t, INTERP_METHOD, INTERP_EXTRAP);
    accZ_i = interp1(t_acc, accZ, t, INTERP_METHOD, INTERP_EXTRAP);
    gyrX_i = interp1(t_acc, gyrX, t, INTERP_METHOD, INTERP_EXTRAP);
    gyrY_i = interp1(t_acc, gyrY, t, INTERP_METHOD, INTERP_EXTRAP);
    gyrZ_i = interp1(t_acc, gyrZ, t, INTERP_METHOD, INTERP_EXTRAP);

    % Build Homer-style aux (if template aux absent, create a struct array)
    % Common Homer fields: name, data, time (not always required)
    aux = struct([]);
    aux(1).name = 'Acc_X';  aux(1).data = accX_i(:);  aux(1).time = t;
    aux(2).name = 'Acc_Y';  aux(2).data = accY_i(:);  aux(2).time = t;
    aux(3).name = 'Acc_Z';  aux(3).data = accZ_i(:);  aux(3).time = t;
    aux(4).name = 'Gyro_X'; aux(4).data = gyrX_i(:);  aux(4).time = t;
    aux(5).name = 'Gyro_Y'; aux(5).data = gyrY_i(:);  aux(5).time = t;
    aux(6).name = 'Gyro_Z'; aux(6).data = gyrZ_i(:);  aux(6).time = t;
end

%% -------- Save .nirs --------
nirs_data = struct('t', t, 'd', d, 'SD', SD, 's', s, 'aux', aux);
save(output_nirs_path, '-struct', 'nirs_data');

disp(['[OK] Saved .nirs: ', output_nirs_path]);
disp(['     Folder: ', pwd]);
