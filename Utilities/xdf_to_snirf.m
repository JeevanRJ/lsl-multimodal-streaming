%% xdf_to_snirf_with_aurora_aux.m
% Convert XDF Aurora stream -> SNIRF
% Uses a template .snirf to copy probe/measurementList/meta tags.
% Adds interpolated aux from Aurora_accelerometer.

clc; clear;

%% ================== USER SETTINGS ==================
xdf_file_path      = 'S1-pr-FPECNF-G-T1.xdf';
template_snirf     = '2024-06-21_001.snirf';
output_snirf       = 'S1-pr-FPECNF-G-T1_fromXDF.snirf';

% Aurora stream rows used for fNIRS
FNIRS_ROW_RANGE = 2:105;

% Which accel sensor(s) to include from Aurora_accelerometer
INCLUDE_SENSOR_11 = true;   % (1,1)
INCLUDE_SENSOR_22 = false;  % (2,2)

INTERP_METHOD = 'linear';
INTERP_EXTRAP = 'extrap';
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
if isempty(aurora_idx), error('Aurora stream not found.'); end
if isempty(accel_idx),  error('Aurora_accelerometer stream not found.'); end

%% -------- Extract fNIRS data --------
aur = streams{aurora_idx};
raw = aur.time_series;
t_fnirs = aur.time_stamps(:);
t_fnirs = t_fnirs - t_fnirs(1);

% Safety: ensure row range exists
if max(FNIRS_ROW_RANGE) > size(raw,1)
    error('FNIRS_ROW_RANGE exceeds available rows in Aurora stream.');
end

fnirs_data = double(raw(FNIRS_ROW_RANGE, :))'; % NxCh
t_fnirs    = double(t_fnirs);

%% -------- Extract accel stream and split sensors --------
acc_stream = streams{accel_idx};
both_acc   = double(acc_stream.time_series);
t_acc_all  = double(acc_stream.time_stamps(:));
t_acc_all  = t_acc_all - t_acc_all(1);

% Helper to create aux channels for one sensor ID pair
make_aux_for_sensor = @(id1,id2,prefix) create_aux_set( ...
    both_acc, t_acc_all, t_fnirs, fnirs_data, id1, id2, prefix, INTERP_METHOD, INTERP_EXTRAP);

aux_list = AuxClass.empty();

k = 0;
if INCLUDE_SENSOR_11
    aux_set = make_aux_for_sensor(1,1,'Acc1');
    for i = 1:numel(aux_set), k=k+1; aux_list(k) = aux_set(i); end %#ok<AGROW>
end
if INCLUDE_SENSOR_22
    aux_set = make_aux_for_sensor(2,2,'Acc2');
    for i = 1:numel(aux_set), k=k+1; aux_list(k) = aux_set(i); end %#ok<AGROW>
end

%% -------- Load template SNIRF & build new --------
template_data = SnirfLoad(template_snirf);
snirf_new = SnirfClass();

snirf_new.formatVersion = template_data.formatVersion;
snirf_new.metaDataTags  = template_data.metaDataTags;
snirf_new.stim          = template_data.stim;
snirf_new.probe         = template_data.probe;
snirf_new.bids          = template_data.bids;

% Optional: customize subject id
snirf_new.metaDataTags.tags.SubjectID = 'from_xdf'; % you can parse from xdf filename

% Create new DataClass
myData = DataClass();
myData.measurementList = template_data.data.measurementList;
myData.cache           = template_data.data.cache;
myData.diagnostic      = template_data.data.diagnostic;
myData.dataTimeSeries  = fnirs_data;
myData.time            = t_fnirs;

snirf_new.data = myData;

% Assign aux
snirf_new.aux = aux_list;

% Save
SnirfSave(output_snirf, snirf_new);
disp(['[OK] Saved SNIRF: ', output_snirf]);

%% ================= LOCAL FUNCTION ====================
function aux_set = create_aux_set(both_acc, t_acc_all, t_fnirs, fnirs_data, id1, id2, prefix, method, extrapMode)
    % Find columns for this sensor id pair
    idx = (both_acc(1,:) == id1) & (both_acc(2,:) == id2);
    if ~any(idx)
        error('No accel samples found for sensor ID pair (%d,%d).', id1, id2);
    end

    acc_sel = both_acc(:, idx);
    inds    = find(idx);
    t_acc   = t_acc_all(inds);
    t_acc   = t_acc - t_acc(1);

    % Extract channels (FIXED)
    accX = acc_sel(3, :);
    accY = acc_sel(4, :);
    accZ = acc_sel(5, :);   % FIX: Z is row 5
    gyrX = acc_sel(6, :);
    gyrY = acc_sel(7, :);
    gyrZ = acc_sel(8, :);

    % Interpolate to fNIRS time base (FIXED gyro Y/Z)
    accX_i = interp1(t_acc, accX, t_fnirs, method, extrapMode);
    accY_i = interp1(t_acc, accY, t_fnirs, method, extrapMode);
    accZ_i = interp1(t_acc, accZ, t_fnirs, method, extrapMode);
    gyrX_i = interp1(t_acc, gyrX, t_fnirs, method, extrapMode);
    gyrY_i = interp1(t_acc, gyrY, t_fnirs, method, extrapMode);
    gyrZ_i = interp1(t_acc, gyrZ, t_fnirs, method, extrapMode);

    % Build AuxClass array
    aux_set = AuxClass.empty();
    aux_set(1) = AuxClass(); aux_set(1).name = [prefix '_AccX'];  aux_set(1).dataTimeSeries = accX_i(:); aux_set(1).time = t_fnirs(:);
    aux_set(2) = AuxClass(); aux_set(2).name = [prefix '_AccY'];  aux_set(2).dataTimeSeries = accY_i(:); aux_set(2).time = t_fnirs(:);
    aux_set(3) = AuxClass(); aux_set(3).name = [prefix '_AccZ'];  aux_set(3).dataTimeSeries = accZ_i(:); aux_set(3).time = t_fnirs(:);
    aux_set(4) = AuxClass(); aux_set(4).name = [prefix '_GyroX']; aux_set(4).dataTimeSeries = gyrX_i(:); aux_set(4).time = t_fnirs(:);
    aux_set(5) = AuxClass(); aux_set(5).name = [prefix '_GyroY']; aux_set(5).dataTimeSeries = gyrY_i(:); aux_set(5).time = t_fnirs(:);
    aux_set(6) = AuxClass(); aux_set(6).name = [prefix '_GyroZ']; aux_set(6).dataTimeSeries = gyrZ_i(:); aux_set(6).time = t_fnirs(:);

    % Optional: timeOffset if present in templates (not required, but can be added)
end
