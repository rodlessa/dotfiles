#!/bin/bash

# Wait 10 seconds after login
sleep 10

# Run undervolting (adjust path if needed)
sudo python3 /home/nykot/Ryzen-5800x3d-linux-undervolting/ruv.py -c 8 -o -30

# Send dunst notification
notify-send "Undervolting applied" "All cores set to -30"
