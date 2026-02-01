#!/bin/sh

set -eu

VERSION="0.1"
CMD=${1:-}
CAPTURES=$HOME/Pictures
RECORDINGS=$HOME/Videos
START_DELAY=0
VIDEO_STREAM=x11
COPY_TO_CLIP=false

PrintUsage() {
	echo "Usage: $0 [task] [options]"
	echo ""
	echo "[task]:"
	echo "   record  - Record The Screen"
	echo "   capture - Capture The Screen"
	echo ""
	echo "[options]:"
	echo "   -v - Print script version"
	echo "   -h - Show this help message"
	echo "   -s - Stream to use from x11 or tty (Default: x11)"
	echo "   -d - Number of seconds to wait before capturing/recording (Default: 0)"
	echo "   -c - Copy captured image to clipboard"
}

if ! [ -x "$(command -v ffmpeg)" ]; then
	echo "error 'ffmpeg' not found, but $0 depends on it."
	exit 1
elif ! [ -x "$(command -v slop)" ]; then
	echo "error 'slop' not found, but $0 depends on it."
	exit 1
elif ! [ -x "$(command -v xclip)" ]; then
	echo "error 'xclip' not found, but $0 depends on it."
	exit 1
fi

OPTIND=2 # We start with 2nd argument since first is a command
while getopts ":d:s:cvh" arg; do
	case "$arg" in
		d) START_DELAY="${OPTARG:-0}";;
		s) VIDEO_STREAM="${OPTARG:-x11}";;
		c) COPY_TO_CLIP=true;;
		v) echo "$0 v$VERSION"; exit 0;;
		h) PrintUsage; exit 0;;
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
case "$START_DELAY" in ''|*[!0-9]*)
	echo "Invalid delay value: '$START_DELAY'"; exit 1 ;;
esac

if [ "$VIDEO_STREAM" = "tty" ] && [ "$(id -u)" -ne 0 ]; then
	echo "Recording tty requires root privelege."
	exit 1
fi

if [ "$CMD" = "record" ]; then
	sleep "${START_DELAY}s"
	FILENAME=Recording-$(date +"%Y-%m-%d-%H-%M-%S").mkv
	mkdir -p "$RECORDINGS"
	if [ "$VIDEO_STREAM" = "x11" ]; then
		POS=$(slop -q -f "%x %y %w %h" || echo "")
		if [ -z "$POS" ]; then
			echo "No area selected to record"
			exit 1;
		fi
		S_X=$(echo "$POS" | cut -d' ' -f1); S_Y=$(echo "$POS" | cut -d' ' -f2)
		S_W=$(echo "$POS" | cut -d' ' -f3); S_H=$(echo "$POS" | cut -d' ' -f4)
		FF_FLAGS="-f x11grab -video_size ${S_W}x${S_H} -i $DISPLAY+${S_X},${S_Y}"
	else
		FF_FLAGS="-f fbdev -i /dev/fb0"
	fi
	ffmpeg                                       \
		-hide_banner                             \
		-loglevel quiet                          \
		$FF_FLAGS                                \
		-c:v libx264rgb                          \
		-crf 0                                   \
		-preset ultrafast                        \
		-color_range 2                           \
		-framerate 30                            \
		-update 1                                \
		"$RECORDINGS/$FILENAME"
		#-f alsa -sample_rate 44100 -i hw:0       \
	echo "Recorded $S_X,$S_Y ${S_W}x${S_H} $FILENAME"
elif [ "$CMD" = "capture" ]; then
	sleep "${START_DELAY}s"
	FILENAME=Screenshot-$(date +"%Y-%m-%d-%H-%M-%S").png
	mkdir -p "$CAPTURES"
	if [ "$VIDEO_STREAM" = "x11" ]; then
		POS=$(slop -q -f "%x %y %w %h" || echo "")
		if [ -z "$POS" ]; then
			echo "No area selected to record"
			exit 1;
		fi
		S_X=$(echo "$POS" | cut -d' ' -f1); S_Y=$(echo "$POS" | cut -d' ' -f2)
		S_W=$(echo "$POS" | cut -d' ' -f3); S_H=$(echo "$POS" | cut -d' ' -f4)
		FF_FLAGS="-f x11grab -video_size ${S_W}x${S_H} -i $DISPLAY+${S_X},${S_Y}"
	else
		FF_FLAGS="-f fbdev -i /dev/fb0"
	fi
	ffmpeg                                       \
		-hide_banner                             \
		-loglevel quiet                          \
		$FF_FLAGS                                \
		-color_range 2                           \
		-frames:v 1                              \
		-framerate 1                             \
		-update 1                                \
		"$CAPTURES/$FILENAME"
	if [ "$COPY_TO_CLIP" = "true" ]; then
		xclip -selection clipboard -t image/png -i "$CAPTURES/$FILENAME"
		echo "Captured $S_X,$S_Y ${S_W}x${S_H} & copied to clipboard"
		rm "$CAPTURES/$FILENAME"
	else
		echo "Captured $S_X,$S_Y ${S_W}x${S_H} $FILENAME"
	fi
elif [ "$CMD" = "-v" ]; then
	echo "$0 v$VERSION";
elif [ "$CMD" = "-h" ]; then
	PrintUsage
else
	PrintUsage
	exit 1
fi

exit 0
