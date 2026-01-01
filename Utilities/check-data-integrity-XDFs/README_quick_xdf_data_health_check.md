# Quick XDF Data Health Check (During Experiments)

This MATLAB script is a **rapid “device still recording?” checker** designed for use **during experiments**.  
It loads a trial `.xdf` file and verifies that the expected LSL streams (Xsens, fNIRS, EMG, Tobii) are:

1. **present** in the XDF, and  
2. **non-empty** (`time_series` and `time_stamps` are not empty)

If anything is missing, it immediately shows a **popup error** listing which device/streams failed and plays a **high-frequency beep**.  
If everything looks good, it shows **“All data okay”** and plays a **low-frequency beep**.

---

## File

- `quick_xdf_data_health_check.m` *(recommended filename)*  
  *(Your current script can keep any name; this is a suggested GitHub-friendly name.)*

Run it directly in MATLAB:
```matlab
quick_xdf_data_health_check
```

---

## When to use

✅ During data collection, right after a trial finishes, to quickly confirm that:
- Xsens streams were recorded
- Aurora fNIRS streams were recorded
- EMG stream exists and contains samples
- Tobii streams exist and contain samples

This is especially useful to detect issues like:
- a device stopped streaming
- LSL stream dropped mid-trial
- a stream failed to start
- a connector cable/battery failure

---

## What it checks

### Expected stream names (by device)

**Xsens**
- `CenterOfMass1`
- `QuaternionDatagram1`
- `EulerDatagram1`
- `AngularKinematics1`
- `LinearSegmentKinematicsDatagram1`
- `TrackerKinematicsDatagram1`

**fNIRS (Aurora)**
- `Aurora`
- `Aurora_accelerometer`

**EMG**
- `EMG`

**Tobii Glasses 3**
- `GazeOrigin`
- `Pupil`
- `GazeDirection`

**Other (optional targets in list)**
- `Gyroscope`, `Accelerometer`, `Gaze3d`, `Gaze2d`, `Magnetometer`

> Note: In the current version, missing “Other” targets are checked for presence, but only Xsens/fNIRS/EMG/Tobii are reported in the popup.

---

## Pass / Fail behavior

### ✅ PASS: all streams present and non-empty
- Popup: **“All data okay”**
- Beep: **low frequency** (100 Hz)

### ❌ FAIL: one or more streams missing or empty
- Popup: **“Data Missing”** + lists which variables are missing by device category
- Beep: **high frequency** (1000 Hz)

---

## How it works (logic summary)

1. Loads the XDF using `load_xdf`.
2. Iterates through all streams in the returned cell array.
3. For each stream, checks:
   - required fields exist (`info`, `time_series`, `time_stamps`)
   - `info.name` matches one of the expected target names
4. Flags missing cases:
   - stream name not found in the file, or
   - stream found but `time_series` or `time_stamps` is empty
5. Shows a GUI popup + plays a beep.

---

## Configuration

Update the XDF filename at the top of the script:
```matlab
dataCellArray = load_xdf('test1.xdf');
```

Update the target stream name lists if your stream names differ:
```matlab
xsensTargets = {...};
fnirsTargets = {...};
emgTargets   = {...};
tobiiTargets = {...};
```

---

## Limitations (by design)

This is a **quick health check**, not a full QC pipeline.

It does **not**:
- verify sampling rates
- check timestamps for gaps/drift
- ensure stream durations match the trial duration
- validate sensor-specific signal quality (e.g., EMG amplitude, fNIRS saturation)

If you want deeper QC, consider adding:
- sample count thresholds
- duration checks vs expected trial length
- a quick plot preview of each stream

---

## Dependencies

- MATLAB
- XDF toolbox providing:
  - `load_xdf`

---

## Suggested enhancements (optional)

- Add an “Other” category to report missing `Gyroscope`, `Accelerometer`, etc.
- Print a compact table with sample counts per stream
- Add a threshold (e.g., “fail if < N samples”)
- Auto-detect trial name and write a log file per session

---

## Summary

This script is a **fast, experiment-friendly sanity check** to catch device dropouts early, before running the next participant or trial.
