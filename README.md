# aunty.sh
aunty that can capture or record your screen

this simple script is a wrapper around ffmpeg to capture and record my screen, since i have ffmpeg already installed for other video editing stuff so why not use it for screen capture/recording.

---
## Usage

```plain
Usage ./aunty.sh v0.1 [task] [options]

[task]:
   record  - Record The Screen
   capture - Capture The Screen

[options]:
   -v - Print script version
   -h - Show this help message
   -s - Stream to use from x11 or tty (Default: x11)
   -d - Number of seconds to wait before capturing/recording (Default: 0)
```

---
## Dependencies

- [ffmpeg](https://repology.org/project/ffmpeg/) - backend for capturing and recording screen.
- [slop](https://repology.org/project/slop/) - for specifying the portion of screen you want to capture/record

---
# Thanks
