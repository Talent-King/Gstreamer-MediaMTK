#!/usr/bin/env bash

# Pick desired defaults
WIDTH=960
HEIGHT=540
FPS=24
BITRATE=1500000

# (Optional) Query caps and adjust dynamically
CAPS=$(gst-device-monitor-1.0 Video/Source | grep avfvideosrc | grep video/x-raw | head -1)
echo "Using caps: $CAPS"

# Launch
# Increase from 20ms to 100ms (100000000 nanoseconds)
gst-launch-1.0 avfvideosrc ! \
  videoconvert ! video/x-raw,format=I420 ! \
  queue max-size-time=100000000 max-size-buffers=0 max-size-bytes=0 leaky=upstream ! \
  videorate ! video/x-raw,framerate=$FPS/4 ! \
  queue max-size-time=100000000 max-size-buffers=0 max-size-bytes=0 leaky=upstream ! \
  vp9enc deadline=1 cpu-used=8 \
    lag-in-frames=0 \
    keyframe-max-dist=48 \
    target-bitrate=$BITRATE \
    end-usage=vbr \
    min-quantizer=4 max-quantizer=63 \
    error-resilient=1 \
    dropframe-threshold=60 \
    resize-allowed=true \
  ! video/x-vp9 ! \
  queue max-size-time=100000000 max-size-buffers=0 max-size-bytes=0 leaky=upstream ! \
  whipclientsink signaller::whip-endpoint=http://mtx-test:8889/mystream/whip \
    congestion-control=gcc \
    min-bitrate=200000 \
    max-bitrate=2000000
