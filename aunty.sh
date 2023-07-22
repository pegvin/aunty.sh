#!/bin/bash

set -e

CMD=$1
OUTDIR=~/Pictures/Screenshots
START_DELAY=0

if   [[ $CMD == "record"  ]]; then
	echo command \'$CMD\' is not implemented yet!
elif [[ $CMD == "capture" ]]; then
	read -r S_X S_Y S_W S_H <<< $(slop -f "%x %y %w %h")
	FILENAME=$(date +"%Y-%m-%d-%H-%M-%S").png
	mkdir -p $OUTDIR
	ffmpeg                                       \
		-f x11grab                               \
		-ss $(date -d@$START_DELAY -u +%H:%M:%S) \ # Converts Start Delay In Seconds To HH:MM:SS format
		-video_size "${S_W}x${S_H}"              \
		-i ":0.0+${S_X},${S_Y}"                  \
		-frames:v 1                              \
		-framerate 1                             \
		$OUTDIR/$FILENAME # > /dev/null 2>&1
	notify-send -i $OUTDIR/$FILENAME "Captured $S_X,$S_Y $S_Wx$S_H $FILENAME"
else
	echo "Usage $0 [task]"
	echo ""
	echo "[task]:"
	echo "   record  - Record The Screen"
	echo "   capture - Capture The Screen"
	exit 1
fi

exit 0

