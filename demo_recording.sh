#!/bin/bash

# Create output directory for the video
mkdir -p ~/Desktop/"Grief Support Demo"

echo "Starting screen recording of Grief Support app..."
echo "Recording will capture:"
echo "1. Main tab navigation"
echo "2. Ask for Help feature"
echo "3. Reminders section"
echo "4. Rituals creation"
echo "5. Resources overview"
echo "6. Settings menu"
echo ""
echo "Press Ctrl+C to stop recording when demo is complete."

# Start recording
xcrun simctl io booted recordVideo --codec=h264 ~/Desktop/"Grief Support Demo"/grief_support_demo.mp4