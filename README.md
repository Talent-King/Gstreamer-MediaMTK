#  rtc

* start the server 
```
cd server
docker compose up -d
# be sure to change the public ip - to some local ip if you are testing in mediamtx
# webRTCAdditionalHosts: [] - enter your ip / could be some local network ip of your docker host
```

# send 
```
./send.sh
# be sure to update this script with the ip from the above section so that it casend right
```
# playback
* playback will be on :8889/mystream
* http://<serverip>:8889/mystream
