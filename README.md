# Swaypaper

Swaypaper is a minimal wrapper and wallpaper daemon for SWWW for the Sway desktop environment. 
It supports minimal wallpaper directories and slideshows from said directories using a minimal file-command structure.

## Usage

> [!NOTE]
> It is, for obvious reasons, highly recommended that you copy Swaypaper into your `/usr/bin` or similar.

After the daemon is started, you can begin to send any commands to it, and it will default to the first directory in your list.

```bash
# Start the daemon
exec swaypaper &
# Switch to the next directory set
swaypaper next
# Back to the previous one
swaypaper prev
# Refresh the wallpaper (cycle to the next one in the current directory set)
swaypaper now
# Stop the daemon
swaypaper stop
```

## Configuration

Swaypaper configuration files are at `~/.config/swaypaper/config` and the daemon hosts a command file (where commands are written to the daemon) at `~/.cache/swaypaper.cmd`

```json
{
    "current": 0,
    "dirs": [
        "~/Pictures/wallpapers/dir1",
        "~\/Pictures/wallpapers/dir2"
    ],
    "interval": 300000,
    "slideshow": "sequential" | "random"
}
```

The `slideshow` parameter may either be "sequential" or "random".
The `interval` parameter dictates interval in 100s of milliseconds (300000 = 5m.)
Formatting will likely be erased when updated by the daemon to store the `current` variable which indicates the currently selected directory set.
