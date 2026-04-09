# raspi-plymouth-custom

A custom Plymouth boot splash theme for Linux-based systems, particularly optimized for Raspberry Pi and embedded devices.

## Overview

This project provides a minimalist image-based Plymouth theme that displays a custom background image during system boot with responsive scaling to fit any screen resolution while maintaining the image's aspect ratio.

## Project Structure

```
raspi-plymouth-custom/
├── README.md                 # Project documentation
├── abit.script              # Plymouth theme script (core logic)
├── abit.plymouth            # Theme configuration file
├── img.png                  # Background image asset (not included*)
└── install.sh               # Installation script
```

### File Descriptions

| File | Purpose |
|------|---------|
| `abit.script` | Main theme logic written in Plymouth script language. Handles image loading, responsive scaling, and message rendering. |
| `abit.plymouth` | Theme metadata and configuration. Defines theme name, description, and module settings for Plymouth daemon. |
| `install.sh` | Deployment script. Requires root privileges. Copies theme files to system directory and sets as default boot theme. |
| `img.png` | **User-provided** background image asset (placeholder name). Must be placed in project root before installation. |

## How It Works

### Theme Flow

1. **Image Loading & Measurement**
   - Loads background image (`img.png`)
   - Detects current screen dimensions

2. **Responsive Scaling**
   - Calculates scale ratios to fit image to screen
   - Applies proportional scaling strategy:
     - If image > screen: Scale down while maintaining aspect ratio, center on shorter axis
     - If image ≤ screen: Scale to fit without distortion, center on both axes

3. **Rendering**
   - Displays scaled image as background sprite
   - Creates message text layer for boot status updates
   - Messages positioned at lower-left corner (90% offset from width and height)

4. **Message Callback**
   - Updates text messages during boot process
   - Maintains background image visibility
   - Non-shutdown mode only (no display during shutdown)

## Requirements

- **OS:** Linux with Plymouth installed
- **Architecture:** Any (tested on Raspberry Pi)
- **Privileges:** Root access for installation
- **Image Asset:** PNG image file named `img.png` in project root

### Dependencies

- Plymouth display daemon
- initramfs-tools (for initramfs update)

## Installation

### Prerequisites

1. Prepare your background image:
   - Convert/resize image to `img.png`
   - Place in project root directory
   - Recommended: PNG format for compatibility

2. Ensure root access (sudo/su)

### Installation Steps

```bash
# Clone or extract this repository
cd raspi-plymouth-custom

# Make install script executable
chmod +x install.sh

# Run installation (requires root)
sudo ./install.sh

# Reboot to apply theme
sudo reboot
```

### What Installation Does

1. Checks for root privileges
2. Creates theme directory: `/usr/share/plymouth/themes/abit/`
3. Copies all project files to theme directory
4. Sets "abit" as default Plymouth theme
5. Updates initramfs with new theme configuration

## Configuration

### Theme Metadata

Edit `abit.plymouth` to customize theme information:

```ini
[Plymouth Theme]
Name=abit                    # Display name
Description=Image Desktop Splash    # Brief description
ModuleName=script           # Engine type (do not change)

[script]
ImageDir=/usr/share/plymouth/themes/abit
ScriptFile=/usr/share/plymouth/themes/abit/abit.script
```

### Changing Background Image

1. Create your PNG image (`img.png`)
2. Place in project root
3. Reinstall using `install.sh`

## Script Reference

### Key Variables (abit.script)

| Variable | Type | Description |
|----------|------|-------------|
| `screen_width`, `screen_height` | int | Current display resolution |
| `theme_image` | Image | Loaded PNG image |
| `resized_image` | Image | Scaled image matching display |
| `image_x`, `image_y` | int | Centered position coordinates |
| `flag` | int | Reserved variable (unused in current version) |

### Scaling Algorithm

The script uses two-stage scaling:

**Stage 1:** Determine if downscaling is needed
- `scale_x = image_width / screen_width`
- `scale_y = image_height / screen_height`

**Stage 2:** Apply appropriate scaling
- If `scale_x > scale_y`: Scale width to screen width, proportional height
- Else: Scale height to screen height, proportional width
- Result: Image fills screen (pillarbox/letterbox as needed)

**Centering:** Scaled image centered on screen using calculated offsets

## Usage

### Normal Operation

After installation and reboot, the theme automatically displays during:
- System boot (splash screen phase)
- Boot status messages overlaid on background

### Temporary Verification

To test without rebooting:

```bash
# View current default theme
sudo plymouth-set-default-theme -C

# Show theme list
sudo plymouth-set-default-theme -l
```

**Note:** Full theme testing requires reboot to see initramfs stage.

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Theme not appearing after install | Initramfs not updated | Re-run `sudo update-initramfs -u -k all` |
| Image doesn't fit screen | Image aspect ratio mismatch | Provide image closer to display aspect ratio |
| Permission denied on install | Not running as root | Use `sudo ./install.sh` |
| `img.png` not found error | Missing image asset | Create/place `img.png` in project root before install |
| Boot hangs with black screen | Theme script error | Verify `abit.script` syntax, check syslog |

## Uninstallation

To remove the custom theme and restore default:

```bash
# List available themes (Plymouth default should be available)
sudo plymouth-set-default-theme -l

# Switch to Ubuntu/default theme
sudo plymouth-set-default-theme ubuntu

# Update initramfs
sudo update-initramfs -u -k all

# Optional: Remove theme directory
sudo rm -rf /usr/share/plymouth/themes/abit/

# Reboot
sudo reboot
```

## Customization Guide

### Adding Boot Messages

The `message_callback` function in `abit.script` handles status text. Currently it:
- Converts text to image
- Renders at fixed position (lower-left)
- Displays over background image

To customize message appearance, modify in `abit.script`:
```c
fun message_callback (text) {
    my_image = Image.Text(text, 1, 1, 1);  // (text, R, G, B)
    message_sprite.SetImage(my_image);
    sprite.SetImage(resized_image);
}
```

### Changing Message Position

Modify message sprite position:
```c
message_sprite.SetPosition(screen_width * 0.1, screen_height * 0.9, 10000);
//                         10% from left    90% from top    z-order
```

## Notes & Limitations

- ⚠️ **Image Asset Not Included:** `img.png` must be user-provided (copyright/licensing consideration)
- ⚠️ **Plymouth Script Language:** Not fully documented. Modifications require understanding Plymouth's proprietary scripting API
- ⚠️ **Boot-Only Display:** Theme only appears during Plymouth daemon initialization (initramfs stage), not during normal desktop operation
- ⚠️ **No Animation Support:** Current implementation is static. Animation would require additional script development
- **Tested On:** Raspberry Pi OS (Debian-based). May require adjustments for other distributions.

## Development Notes

### Scaling Logic Explanation

The script eliminates empty space by:
1. Comparing image and screen aspect ratios
2. Scaling the longer dimension to screen size
3. Proportionally scaling the shorter dimension
4. Result: Image covers screen with no stretching

**Example:**
- Image: 1920×1080 (16:9)
- Screen: 1024×768 (4:3)
- Scale result: 1024×576 (letterbox with bars top/bottom)



## Support

For issues specific to:
- **Plymouth:** See [Plymouth Project Documentation](https://cgit.freedesktop.org/plymouth/)
- **Raspberry Pi:** Check [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)
- **Boot Process:** Review system logs: `sudo journalctl -b`

---

**Version:** 1.0  
**Last Updated:** 2026-04-09
