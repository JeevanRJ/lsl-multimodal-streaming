import csv
from datetime import datetime
from pynput import mouse
import os

if os.path.exists("mouse_clicks.csv"):
        os.remove("mouse_clicks.csv")

# Function to write the click information to a CSV file
def log_click(button, timestamp):       
    with open('mouse_clicks.csv', 'a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([button, timestamp])

# Callback function for mouse click events
def on_click(x, y, button, pressed):
    if pressed:
        timestamp = datetime.now().strftime('%Y_%m_%d_%H_%M_%S_%f')[:-3]
        # timestamp = datetime.now().strftime('%H:%M:%S.%f')[:-3]
        log_click(button, timestamp)
        print(f'{button} clicked at {timestamp}')

# Set up the listener
with mouse.Listener(on_click=on_click) as listener:
    listener.join()
