# Roblox Lifting Simulator Auto-Clicker & Anti-AFK Script

This AutoHotkey script serves two main purposes:
1. **Auto-Clicker**: Automatically performs mouse clicks at random intervals to help with repetitive clicking tasks in Lifting Simulator
2. **Anti-AFK System**: Prevents Roblox from detecting inactivity by simulating random key presses and movements

The script uses randomized timing and movement patterns to appear more human-like and avoid detection while you're away from the keyboard.

## About This Project

This project documentation was created with Cline, an AI assistant, to demonstrate to my 10-year-old child what AI tools can be used for. It shows how AI can help with tasks like documentation, code explanation, and project organization.

## Disclaimer

**Use at your own risk.** This script is provided for educational purposes only. Using automation tools like this may violate Roblox's terms of service and could potentially result in account suspension or banning.

The creator's opinion: Lifting Simulator is a repetitive game that primarily involves pressing buttons to lift weights with minimal gameplay variety. This script was created to automate these repetitive actions, but remember that using such tools is generally not recommended in online games.

## Requirements

- AutoHotkey v2.0
- Windows operating system
- Roblox Lifting Simulator game

## Installing AutoHotkey 2.0

1. Visit the [AutoHotkey download page](https://www.autohotkey.com/)
2. Download the AutoHotkey v2.0 installer
3. Run the installer and follow the on-screen instructions
4. Restart your computer if prompted

## Features

- **Anti-AFK System**: Prevents the game from detecting inactivity
- **Random Timing**: Uses randomized intervals for all actions to avoid detection
- **Weapon Switching**: Automatically switches between weapons 1 and 2
- **Movement Simulation**: Randomly presses WASD keys in unpredictable patterns
- **Mouse Click Automation**: Performs clicks at random intervals
- **On-Screen HUD**: Displays current status and statistics (toggle with F10) - visible in windowed mode (F11), works but not visible in full screen
- **Instant Deactivation**: Quickly disable with F9 or Pause key

## How to Use

1. Download the `Roblox-LifftingSimulator.ahk` script
2. Double-click the script to run it (requires AutoHotkey v2.0 to be installed)
3. Open Roblox and join Lifting Simulator
4. Press **F9** to arm the script
5. The script will activate automatically after 5 seconds of inactivity
6. The on-screen HUD will show the current status and statistics
7. To disable the script, press **F9** again
8. To toggle the HUD display, press **F10**
9. For best experience with the HUD, use windowed mode (toggle with **F11** in Roblox)
10. Note that the HUD functions in full screen mode but is not visible
11. To suspend the script completely, press the **Pause** key

## Controls

- **F9**: Toggle between ARMED and DISABLED states
- **F10**: Toggle the on-screen HUD
- **Pause**: Suspend the script entirely

## Configuration

You can customize the script's behavior by modifying the values in the `CONFIGURATION` section at the top of the script. Here's what each setting does:

| Setting | Default Value | Description |
|---------|---------------|-------------|
| `WaitTime` | 5000 | Time in milliseconds of inactivity before automation starts (5 seconds) |
| `TargetWin` | "Roblox" | Part of the window title that identifies the game window |
| `Debug` | true | HUD visibility (can be toggled with F10) |
| `ClickMin` | 100 | Minimum click interval in milliseconds (0.1 seconds) |
| `ClickMax` | 300 | Maximum click interval in milliseconds (0.3 seconds) |
| `MoveMin` | 60000 | Minimum time between movement sequences in milliseconds (60 seconds) |
| `MoveMax` | 90000 | Maximum time between movement sequences in milliseconds (90 seconds) |
| `MouseThresh` | 10 | Pixel threshold for mouse movement that stops automation |
| `BlackoutOffset` | 100 | Millisecond offset for weapon switching click blackout |
| `MovementKeyHoldMin` | 400 | Minimum time to hold movement keys (WASD) in milliseconds |
| `MovementKeyHoldMax` | 800 | Maximum time to hold movement keys (WASD) in milliseconds |
| `WeaponKeyHoldMin` | 50 | Minimum time to hold weapon keys (1,2) in milliseconds |
| `WeaponKeyHoldMax` | 100 | Maximum time to hold weapon keys (1,2) in milliseconds |
| `KeyPauseDuration` | 50 | Pause between key actions in milliseconds |

### How to Modify Configuration

1. Open the `Roblox-LifftingSimulator.ahk` file in a text editor:
   - Right-click on the file
   - Select "Edit" or "Edit with Notepad"
   - Alternatively, you can open Notepad first (Start menu > Notepad), then go to File > Open and navigate to the script file

2. Locate the `CONFIGURATION` section at the top of the file (it should look like this):
   ```
   ; ────────────────────────────────────────────────────────────────
   ; CONFIGURATION
   ; ────────────────────────────────────────────────────────────────
   WaitTime  := 5000             ; ms inactivity before automation starts (5 s)
   TargetWin := "Roblox"         ; part of window title that identifies the game
   Debug     := true             ; HUD on/off (F10 toggles)
   ```

3. Change the values as needed (only modify the numbers, not the variable names)
4. Save the file (File > Save or Ctrl+S)
5. Close Notepad
6. Restart the script if it's already running

For example, to make the script wait longer before starting automation, you could change `WaitTime := 5000` to `WaitTime := 10000` to make it wait 10 seconds instead of 5.

## How It Works

The script uses a state machine with three states:

1. **DISABLED**: Script is inactive
2. **ARMED**: Script is ready but waiting for inactivity
3. **RUNNING**: Script is actively simulating inputs

When in the RUNNING state, the script:
- Performs mouse clicks at random intervals (100-300ms)
- Simulates random movement patterns using WASD keys
- Switches between weapons 1 and 2
- Monitors for user activity to automatically disable itself

Any mouse movement or keyboard input from the user will automatically return the script to the ARMED state.

## Support the Developer

If you find this script useful, consider buying me a coffee!

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/dkmaker)

## License

This project is released under the MIT License. This means:

- You can use it for any purpose, including commercial use
- You can modify, distribute, or sell it
- You must include the original copyright notice and license in any copy of the software/source
- You must give credit to the original author (attribution)
- The software is provided "as is" with no warranties

See the [LICENSE](LICENSE) file for the full text of the MIT License.

**Note:** Remember to update the LICENSE file with your name in place of "[YOUR NAME]".
