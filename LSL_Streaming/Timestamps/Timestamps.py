"""
File: Timestamps.py
Author: Kieran Nichols (knichols4@wisc.edu) and Jeevan Ayasuriyaar (jayasuriyaar@wisc.edu)
Date: 8/5/24
Description: This script generates timestamps and streams them on LSL. 
The timestamps are generated at a fixed sampling rate and the effective sampling rate 
is calculated based on the time difference between consecutive timestamps. 
The script can be used to simulate a timestamp stream for testing purposes.
"""

import time
import pylsl
from pylsl import StreamInfo, StreamOutlet

def main():
    # Define stream information
    stream_name = 'TimestampStream'
    stream_type = 'Timestamps'
    stream_id = 'UniqueStreamID12345'  # Change this to a unique identifier for your stream
    srate = 50
    prev_timestamp = None
    effective_srate = 0
    time_diff = 0.0
    time_elapsed = 0

    # Create a stream outlet
    info = StreamInfo(stream_name, stream_type, 1, srate, pylsl.cf_string, stream_id)
    outlet = StreamOutlet(info)
    
    print(f'Streaming timestamps on LSL with stream ID: {stream_id}')
    
    # Generate and stream timestamps
    while True:
        curr_time = time.time()
        timestamp = int(curr_time * 1000)  # Get current time in milliseconds
        
        # Calculate effective sampling rate
        if prev_timestamp:
            time_diff = curr_time - prev_timestamp
            if time_diff > 0:
                effective_srate = 1.0 / time_diff
            
        # Update previous timestamp
        prev_timestamp = curr_time
        timestamp_str = str(timestamp)
        outlet.push_sample([timestamp_str])
        
        time_elapsed = (1/srate)-time_diff
        time.sleep(max(0,time_elapsed))  # Adjust the sleep time as needed for your application
        print(f"Timestamp sent: {timestamp_str}, {time_diff}")
        
if __name__ == "__main__":
    main()
