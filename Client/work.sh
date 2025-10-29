#!/bin/bash

# -----------------------------
# Configuration
# -----------------------------
V4L2_DEVICE="/dev/video1"            # virtual camera (v4l2loopback)
AUDIO_DEVICE="default"                # microphone or can be skipped
MTX_URL="http://localhost:8889/mystream/whip"

# Video settings
WIDTH=640
HEIGHT=480
FPS_MAX=30
BITRATE=500000
MIN_BITRATE=200000
MAX_BITRATE=2000000
RECONNECT_DELAY=5
--------------------
# Step 2: Stream virtual camera to WHIP
# -----------------------------
stream_whip() {
  echo "🎬 Streaming virtual camera $V4L2_DEVICE to WHIP $MTX_URL ..."
  gst-launch-1.0 -v \
    videotestsrc is-live=true ! \
      videoconvert ! \
      queue max-size-time=100000000 max-size-buffers=0 max-size-bytes=0 leaky=upstream ! \
      videorate ! video/x-raw,format=I420,width=$WIDTH,height=$HEIGHT,framerate=$FPS_MAX/1 ! \
      videoconvert ! \
      queue max-size-time=100000000 max-size-buffers=0 max-size-bytes=0 leaky=upstream ! \
      vp9enc deadline=1 cpu-used=8 lag-in-frames=0 keyframe-max-dist=48 \
        target-bitrate=$BITRATE end-usage=vbr min-quantizer=4 max-quantizer=63 \
        error-resilient=1 dropframe-threshold=60 resize-allowed=true ! \
      queue ! mux. \
    whipclientsink name=mux signaller::whip-endpoint=$MTX_URL \
      congestion-control=gcc min-bitrate=$MIN_BITRATE max-bitrate=$MAX_BITRATE
}

# -----------------------------
# Step 3: Automatic reconnection loop
# -----------------------------
while true; do
  stream_whip
  echo "⚠️ Stream disconnected. Reconnecting in $RECONNECT_DELAY seconds..."
  sleep $RECONNECT_DELAY
done


