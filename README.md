# aunty.sh
This simple POSIX-shell compliant script uses `ffmpeg`
to capture/record your screen. You can either record
your X11 session or TTY.

---
## Usage

```plain
Usage: ./aunty.sh [task] [options]

[task]:
   record  - Record The Screen
   capture - Capture The Screen

[options]:
   -v - Print script version
   -h - Show this help message
   -s - Stream to use from x11 or tty (Default: x11)
   -d - Number of seconds to wait before capturing/recording (Default: 0)
   -c - Copy captured image to clipboard
```

**Note**: press <kbd>Ctrl</kbd> + <kbd>C</kbd> to stop the recording.

## Dependencies

- [ffmpeg](https://repology.org/project/ffmpeg/) - For capturing and recording screen.
- [slop](https://repology.org/project/slop/) - For specifying the portion of screen you want to capture/record
- [xclip](https://repology.org/project/xclip/) - To optionally copy captured image to clipboard.

