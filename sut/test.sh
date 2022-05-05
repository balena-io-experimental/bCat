#!/bin/bash

echo "setting up fingerprint check"
cd audfprint
# pip install -r requirements.txt

python audfprint.py new --dbase fpdbase.pklz ../test.wav 

echo "Waiting for audio block to activate..."

sleep 10

#start recording 
echo "Start recording"
arecord -f S16_LE -D hw:1,0 -d 40 ../result.wav &

# play sample 
mplayer ../test.wav 

# compare! Should exit with a 1 if fails, 0 if succeeds
python audfprint.py match --dbase fpdbase.pklz ../result.wav | grep Matched


