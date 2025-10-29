VIDEO_FILE="video.mp4"
MTX_URL="http://localhost:8889/mystream/whip"
BITRATE=500000

# (Optional) Query caps and adjust dynamically
CAPS=$(gst-device-monitor-1.0 Video/Source | grep avfvideosrc | grep video/x-raw | head -1)
echo "Using caps: $CAPS"

echo "🎬 Streaming $VIDEO_FILE to $MTX_URL ..."

gst-launch-1.0 -v \
  filesrc location="$VIDEO_FILE" ! qtdemux name=demux \
  demux.audio_0 ! queue ! decodebin ! audioconvert ! audioresample ! opusenc ! \
  whipclientsink signaller::whip-endpoint=$MTX_URL 
