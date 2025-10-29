#!/bin/bash

MTX_URL="http://localhost:8889/mystream/whip"
VIDEO_BITRATE=500000

CAPS=$(v4l2-ctl --list-devices)
echo "Using caps: $CAPS"

echo "🎬 Streaming webcam + microphone to $MTX_URL ..."

# gst-launch-1.0 filesrc location=video.mp4 ! decodebin ! videoconvert ! v4l2sink device=/dev/video1

gst-launch-1.0 -v \
  videotestsrc is-live=true ! video/x-raw,format=I420,width=640,height=480,framerate=30/1 ! \
  x264enc tune=zerolatency bitrate=500000 speed-preset=ultrafast ! queue ! mux. \
  audiotestsrc is-live=true ! audioconvert ! audioresample ! opusenc ! queue ! mux. \
  whipclientsink name=mux signaller::whip-endpoint="http://localhost:8889/mystream/whip"
