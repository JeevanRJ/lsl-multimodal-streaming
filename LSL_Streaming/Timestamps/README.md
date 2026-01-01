# README

## Timestamps.py

### Authors:
- Kieran Nichols (knichols4@wisc.edu)
- Jeevan Ayasuriyaar (jayasuriyaar@wisc.edu)

### Date: 8/5/24

### Description:
This script generates timestamps and streams them using the Lab Streaming Layer (LSL). The timestamps are generated at a fixed sampling rate, and the effective sampling rate is calculated based on the time difference between consecutive timestamps. This script can be used to simulate a timestamp stream for testing purposes.

## Requirements:
- Python 3.x
- pylsl (Python library for LSL)

## Installation:
1. **Python Installation**: Ensure you have Python installed on your system. You can download it from [python.org](https://www.python.org/downloads/).
2. **pylsl Installation**: Install the pylsl library using pip:
    ```bash
    pip install pylsl
    ```

## Usage:
1. **Script Configuration**: 
   - The stream is configured with a name (`TimestampStream`), type (`Timestamps`), and a unique identifier (`UniqueStreamID12345`). 
   - The sampling rate is set to 50 Hz.

2. **Running the Script**:
   - Execute the script using the following command:
     ```bash
     python Timestamps.py
     ```

3. **Script Functionality**:
   - The script creates an LSL stream outlet with the specified stream information.
   - It then enters an infinite loop where it generates a timestamp, calculates the effective sampling rate, and streams the timestamp via LSL.
   - The script ensures that timestamps are generated at the specified sampling rate by adjusting the sleep time between iterations.

## Code Overview:

### Main Function:
- **Stream Information Setup**:
  - `stream_name`: Name of the LSL stream.
  - `stream_type`: Type of the LSL stream.
  - `stream_id`: Unique identifier for the stream.
  - `srate`: Sampling rate in Hz.

- **Stream Outlet Creation**:
  - Creates an LSL stream outlet with the defined stream information.

- **Streaming Loop**:
  - Generates current time in milliseconds as the timestamp.
  - Calculates the effective sampling rate based on the time difference between consecutive timestamps.
  - Pushes the timestamp as a sample to the LSL stream outlet.
  - Adjusts the sleep time to maintain the fixed sampling rate.

### Example Output:
- Streaming timestamps on LSL with stream ID: UniqueStreamID12345
- Timestamp sent: 1628201234567, 0.02
- Timestamp sent: 1628201234587, 0.02

## Notes:
- Ensure that the `stream_id` is unique for each stream to avoid conflicts.
- Adjust the sleep time calculation if the effective sampling rate deviates significantly from the desired rate.
- The script runs indefinitely until manually terminated.

## License:
This script is provided as-is without any warranty. Feel free to modify and use it as needed for your applications.
