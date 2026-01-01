# XDF → fNIRS Conversion Utilities (`.nirs` + `.snirf`)

This folder provides two MATLAB scripts that convert **Aurora fNIRS streams recorded in XDF (Lab Streaming Layer)** into formats commonly used in fNIRS workflows:

- **Homer-style `.nirs`** (MATLAB struct)
- **SNIRF `.snirf`** (standardized fNIRS container)

Both scripts:
1) load an `.xdf` file (via the XDF toolbox),
2) extract the **Aurora** stream as fNIRS data,
3) normalize time to start at `t = 0`,
4) copy probe/channel metadata from a **template file** recorded with the same montage,
5) (optionally) extract `Aurora_accelerometer` and align aux data to the fNIRS timeline.

---

## Files

### 1) `xdf_to_nirs.m`
**Purpose:** Convert an XDF file to a Homer-compatible `.nirs` file using a template `.nirs` file for `SD` (probe definition).  
Optionally, it can populate `aux` using interpolated accelerometer/gyroscope channels from the XDF.

**Output format:** MATLAB struct saved with:
- `t` : Nx1 time vector (seconds)
- `d` : NxCh fNIRS data matrix
- `SD`: probe/channel structure copied from template `.nirs`
- `s` : Nx1 stimulus vector (zeros by default)
- `aux`: auxiliary channels (either template aux or interpolated Acc/Gyro)

**Typical use:** Analyze in **Homer2/Homer3** or any pipeline expecting a Homer `.nirs` struct.

---

### 2) `xdf_to_snirf.m`
**Purpose:** Convert an XDF file to a `.snirf` file using a template `.snirf` to copy `probe`, `measurementList`, and metadata, and then write fNIRS data + interpolated auxiliary channels.

**Output format:** SNIRF object saved with:
- `snirf.data.dataTimeSeries` and `snirf.data.time`
- `snirf.probe`, `snirf.data.measurementList` copied from template
- `snirf.aux(i)` containing interpolated Acc/Gyro channels (configurable)

**Typical use:** Use with **SNIRF-compatible tools** (e.g., MNE-NIRS, Brainstorm/NIRSTORM, custom SNIRF workflows).

---

## Requirements

### MATLAB dependencies
- **XDF toolbox** (must provide `load_xdf`)
- **SNIRF MATLAB toolbox** (only required for `xdf_to_snirf.m`):  
  `SnirfLoad`, `SnirfSave`, `SnirfClass`, `DataClass`, `AuxClass`

### Required input files
- An **XDF** recording containing streams:
  - `Aurora`
  - `Aurora_accelerometer` (optional but recommended)
- A **template file** recorded with the same montage:
  - Template `.nirs` for `xdf_to_nirs.m`
  - Template `.snirf` for `xdf_to_snirf.m`

> **Why templates?**  
> XDF/LSL generally stores raw time-series but not complete probe geometry/channel definitions.  
> These scripts copy probe/channel metadata from a known-good template.

---

## Quick Start

### A) Convert XDF → `.nirs`
1. Open `xdf_to_nirs.m`
2. Set:
   - `xdf_file_path`
   - `template_nirs_path`
   - `output_nirs_path`
3. Run the script.

---

### B) Convert XDF → `.snirf`
1. Open `xdf_to_snirf.m`
2. Set:
   - `xdf_file_path`
   - `template_snirf`
   - `output_snirf`
3. (Optional) choose which accelerometer(s) to include (if the script exposes toggles)
4. Run the script.

---

## Key Assumptions (Important)

### 1) Aurora channel row range
Both scripts commonly use something like:
```matlab
FNIRS_ROW_RANGE = 2:105;
```
This assumes rows 2–105 in `Aurora.time_series` correspond to the fNIRS measurement channels.

If your Aurora stream layout differs, update `FNIRS_ROW_RANGE`.

---

### 2) Accelerometer stream encoding
The scripts assume `Aurora_accelerometer.time_series` uses:
- Row 1 and Row 2 as **sensor IDs** (e.g., (1,1) and (2,2))
- Rows:
  - 3 = AccX
  - 4 = AccY
  - 5 = AccZ
  - 6 = GyroX
  - 7 = GyroY
  - 8 = GyroZ

Aux channels are interpolated onto the fNIRS time base using:
```matlab
interp1(t_acc, x_acc, t_fnirs, 'linear', 'extrap')
```

---

### 3) Metadata alignment
These scripts assume the **ordering of extracted fNIRS channels matches the template probe/channel definitions**.

If the template montage differs from the XDF channel ordering, you must remap channels before saving.

---

## Troubleshooting

### “Aurora stream not found”
Confirm the XDF contains a stream named exactly `Aurora`.  
You can inspect `streams{i}.info.name` after `load_xdf`.

### “Aurora_accelerometer stream not found”
If your recording doesn’t include accel:
- `.nirs` script: disable accel usage (if the script has a toggle)
- `.snirf` script: remove/skip aux creation

### NaNs after interpolation
Can occur if accel timestamps don’t overlap with fNIRS timestamps.
- Ensure both streams cover the same time window.
- Consider trimming to overlap before interpolation.

### Wrong probe geometry / wrong channels
Use a template recorded with the same cap placement and Aurora channel configuration.

---

## Suggested repo structure

```
/conversion
  xdf_to_nirs.m
  xdf_to_snirf.m
  README.md
/templates
  template.nirs
  template.snirf
/data
  (your .xdf files)
```

---

## License / attribution
If you adapted these scripts from others, keep attribution in the header comments and follow the original license requirements.  
If you wrote modifications, you may apply your repo license (e.g., MIT) while preserving any upstream notices.
