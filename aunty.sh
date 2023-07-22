#!/bin/bash

set -e

function PrintUsage() {
	echo "Usage $0 [task] [options]"
	echo ""
	echo "[task]:"
	echo "   record  - Record The Screen"
	echo "   capture - Capture The Screen"
	echo ""
	echo "[options]:"
	echo "   -s - Stream to use from x11 or tty (Default: x11)"
	echo "   -d - Number of seconds to wait before capturing/recording (Default: 0)"
}

if ! command ffmpeg -version &> /dev/null; then
	echo "error 'ffmpeg' not found, but $0 depends on it."
	exit 1
elif ! command slop --version &> /dev/null; then
	echo "error 'slop' not found, but $0 depends on it."
	exit 1
fi

CMD=$1
CAPTURES=~/Pictures/
RECORDINGS=~/Videos/
START_DELAY=0
VIDEO_STREAM=x11

((OPTIND++)) # Since first argument is expected to be a command
while getopts ":d:s:" arg; do
	case $arg in
		d) START_DELAY="${OPTARG:-0}";;
		s) VIDEO_STREAM="${OPTARG:-x11}";;
		\?) echo "Invalid option: '$OPTARG'"; PrintUsage; exit 1;;
	esac
done

case "$VIDEO_STREAM" in "tty"|"x11")
	;;
*)
	echo "Invalid stream value: '$VIDEO_STREAM'";
	exit 1
esac

# https://stackoverflow.com/a/3951175/14516016
case $START_DELAY in ''|*[!0-9]*)
	echo "Invalid delay value: '$START_DELAY'"; exit 1 ;;
esac

if [[ $VIDEO_STREAM == "tty" ]] && [ "$EUID" -ne 0 ]; then
	echo "Recording tty requires root privelege."
	exit 1
fi

if   [[ $CMD == "record"  ]]; then
	FILENAME=$(date +"%Y-%m-%d-%H-%M-%S").mkv
	mkdir -p $RECORDINGS
	if [[ $VIDEO_STREAM == "x11" ]]; then
		read -r S_X S_Y S_W S_H <<< $(slop -f "%x %y %w %h")
		FF_FLAGS="-f x11grab -video_size ${S_W}x${S_H} -i :0.0+${S_X},${S_Y}"
	else
		FF_FLAGS="-f fbdev -i /dev/fb0"
	fi
	ffmpeg                                       \
		-hide_banner                             \
		-framerate 30                            \
		$FF_FLAGS                                \
		-ss $(date -d@$START_DELAY -u +%H:%M:%S) \
		-c:v libx264rgb                          \
		-crf 0                                   \
		-preset ultrafast                        \
		-color_range 2                           \
		$RECORDINGS/$FILENAME > /dev/null 2>&1
	notify-send "Recorded $S_X,$S_Y $S_Wx$S_H $FILENAME"
elif [[ $CMD == "capture" ]]; then
	FILENAME=$(date +"%Y-%m-%d-%H-%M-%S").png
	mkdir -p $CAPTURES
	if [[ $VIDEO_STREAM == "x11" ]]; then
		read -r S_X S_Y S_W S_H <<< $(slop -f "%x %y %w %h")
		FF_FLAGS="-f x11grab -video_size ${S_W}x${S_H} -i :0.0+${S_X},${S_Y}"
	else
		FF_FLAGS="-f fbdev -i /dev/fb0"
	fi
	ffmpeg                                       \
		-hide_banner                             \
		-framerate 1                             \
		$FF_FLAGS                                \
		-ss $(date -d@$START_DELAY -u +%H:%M:%S) \
		-frames:v 1                              \
		-crf 0                                   \
		-preset ultrafast                        \
		-color_range 2                           \
		$CAPTURES/$FILENAME > /dev/null 2>&1
	notify-send -i $CAPTURES/screenshot-$FILENAME "Captured $S_X,$S_Y $S_Wx$S_H $FILENAME"
else
	PrintUsage
	exit 1
fi

exit 0

