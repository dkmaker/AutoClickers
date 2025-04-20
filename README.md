# Roblox Lifting Simulator Anti-AFK Script

This AutoHotkey script prevents Roblox from detecting inactivity in Lifting Simulator by simulating random key presses and mouse clicks when you're away from the keyboard.

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
