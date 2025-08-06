# Quake Window Toggle

A simple script to create a quake-style dropdown terminal window in KDE. Toggle your terminal with a keyboard shortcut for quick access.

## Features

- Toggle show/hide terminal window with keyboard shortcut
- Automatically launches terminal if not running
- Remembers window state between toggles
- Configurable for different terminal applications

## Setup

### 1. Configure the Script

Edit `toggle-window.sh` to set your preferred terminal:

```bash
QUAKE_APP_CLASS="Wave"                    # Window class name
QUAKE_APP_COMMAND="/usr/bin/waveterm"     # Command to launch the app
```

### 2. Set Up Keyboard Shortcut

1. Open **System Settings** → **Shortcuts** → **Custom Shortcuts**
2. Click **Edit** → **New** → **Global Shortcut** → **Command/URL**
3. Set the command to the full path of `toggle-window.sh`
4. Assign your preferred key combination (e.g., `F12` or `Ctrl+~`)

### 3. Configure Window Rules

1. Open **System Settings** → **Window Management** → **Window Rules**
2. Create a new rule for your terminal application
3. Set the window class to match your `QUAKE_APP_CLASS` (e.g., "Wave")
4. Configure properties:
   - **Size & Position**: Set desired width/height and position
   - **Arrangement & Access**: Enable "Keep above other windows"
   - **Appearance & Fixes**: Set any other desired behaviors

## Requirements

- KDE Plasma desktop environment
- `kdotool` (usually included with KDE)
- Your chosen terminal application

## Usage

Press your configured keyboard shortcut to toggle the terminal window. The script will:
- Show the terminal if hidden
- Hide (minimize) the terminal if shown
- Launch the terminal if not running

## License

MIT License - see [LICENSE](LICENSE) for details.