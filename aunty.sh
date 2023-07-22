#!/bin/bash

set -e

if ! command ffmpeg -version &> /dev/null; then
	echo "error 'ffmpeg' not found, but $0 depends on it."
	exit 1
elif ! command slop --version &> /dev/null; then
	echo "error 'slop' not found, but $0 depends on it."
	exit 1
fi

CMD=$1
CAPTURES=~/Pictures/Screenshots/
RECORDINGS=~/Videos/Recordings/
START_DELAY=0

if   [[ $CMD == "record"  ]]; then
	read -r S_X S_Y S_W S_H <<< $(slop -f "%x %y %w %h")
	FILENAME=$(date +"%Y-%m-%d-%H-%M-%S").mkv
	mkdir -p $RECORDINGS
	ffmpeg                                       \
		-hide_banner                             \
		-video_size "${S_W}x${S_H}"              \
		-framerate 30                            \
		-f x11grab                               \
		-i ":0.0+${S_X},${S_Y}"                  \
		-ss $(date -d@$START_DELAY -u +%H:%M:%S) \
		-c:v libx264rgb                          \
		-crf 0                                   \
		-preset ultrafast                        \
		-color_range 2                           \
		$RECORDINGS/$FILENAME > /dev/null 2>&1
	notify-send -i $CAPTURES/$FILENAME "Recorded $S_X,$S_Y $S_Wx$S_H $FILENAME"
elif [[ $CMD == "capture" ]]; then
	read -r S_X S_Y S_W S_H <<< $(slop -f "%x %y %w %h")
	FILENAME=$(date +"%Y-%m-%d-%H-%M-%S").png
	mkdir -p $CAPTURES
	ffmpeg                                       \
		-hide_banner                             \
		-f x11grab                               \
		-ss $(date -d@$START_DELAY -u +%H:%M:%S) \
		-video_size "${S_W}x${S_H}"              \
		-i ":0.0+${S_X},${S_Y}"                  \
		-frames:v 1                              \
		-framerate 1                             \
		$CAPTURES/$FILENAME > /dev/null 2>&1
	notify-send -i $CAPTURES/$FILENAME "Captured $S_X,$S_Y $S_Wx$S_H $FILENAME"
else
	echo "Usage $0 [task] [options]"
	echo ""
	echo "[task]:"
	echo "   record  - Record The Screen"
	echo "   capture - Capture The Screen"
	echo ""
	echo "[options]:"
	echo "   --stream      - Stream To Record From (Available: x11 or tty)"
	echo "   --start-delay - Number of seconds to wait before capturing/recording"
	exit 1
fi

exit 0

