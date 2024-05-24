# Tribes Loadout Manager

This script is designed to manage loadouts for the game "Tribes". It allows you to quickly switch between different loadouts using hotkeys. 

## Requirements

- [AutoHotKey 2.0](https://www.autohotkey.com/v2/)

## Optional

- [Rainmeter](https://docs.rainmeter.net/)

## Features

- Change custom loadouts with a single key press.
- Loadout hotkeys can cycle between multiple loadouts (blink, thrust etc.)
- Rainmeter HUD that provides status of current loadout.
- Enable or disable the script with a hotkey.
- Toggle between two weapons with he same key (Experimental)

## Configuration

Edit the configuration area in the script to customize it to your needs.

- `KEY_CHANGE_LOADOUT`: The key to bring up the loadout change menu. Default is `k`.
- `KEY_ENABLED`: The key to enable or disable the script. Default is `^k` (Ctrl + k).
- `NOTIFY_ENABLED`: Whether to show a toast notification when the script is enabled or disabled. Default is `true`.
- `NOTIFY_INVENTORY`: Whether to show a toast notification when a loadout is applied via hotkey. Default is `true`.
- `SCREEN_SIZE`: Set your screen size. Supported values are `1080` and `1440`.

### Rainmeter Settings

- `ENABLE_RAINMETER`: Turn on and off the Rainmeter loadout HUD.
- `PATH_RAINMETER`: Set this path if you have "Rainmeter" installed. Should be set to the default.

### Inventory Loadout Hotkeys

Define your loadouts with hotkeys and loadout configurations. 

```
HotKey = Keyboard Key (make sure not already bound in game, try "F1" ...)

Loadout = [class, w1, w2, w3, belt, pack]

    class: "pathfinder", "sentinel", "raider", "technician", "doombringer", "juggernaut"
    w1: "spinfusor", "bolt", "thumper", "plasma"
    w2: "chain", "phase", "grenade", "nova", "mortar", "gladiator", "plasma"
    w3: "sparrow", "shotgun", "nova", "shocklance"
    belt: "explosive", "chaff", "smoke", "impact", "sticky", "ap", "frag", "disc", "mine"
    pack: "blink", "thrust", "stealth", "turret", "shield", "phase", "dome", "regen", "forcefield"

Inventory = {
    [HotKey]: Loadout | Loadout[]
}
```

Example:
\`\`\`ahk
INVENTORY := Map(
    "F1", [
        ["pathfinder", "spinfusor", "chain", "shotgun", "explosive", "thrust"],
        ["pathfinder", "spinfusor", "chain", "shotgun", "explosive", "blink"],
    ],
    "F2", [
        ["sentinel", "spinfusor", "chain", "shotgun", "impact", "blink"],
        ["sentinel", "spinfusor", "chain", "shotgun", "impact", "thrust"],
    ],
    "F3", ["raider", "spinfusor", "chain", "shotgun", "ap", "shield"],
    "F4", ["technician", "spinfusor", "chain", "shotgun", "ap", "turret"],
    "F5", ["doombringer", "spinfusor", "mortar", "shotgun", "disc", "shield"],
    "F6", ["juggernaut", "spinfusor", "chain", "shotgun", "disc", "forcefield"],
)
\`\`\`

### Weapon Swap (Experimental)

- `ENABLE_WEAPON_SWAP`: Enable or disable weapon swap functionality. Default is `false`.
- `KEY_WEAPON_SWAP`: The key to swap between two weapons. Default is `q`.
- `KEY_WEAPON_1`: The key binding for the first weapon. Default is `p`.
- `KEY_WEAPON_2`: The key binding for the second weapon. Default is `o`.

## Usage

1. Install AutoHotkey v2.0 or later.
2. Download `t3invo.ahk` from this repo.
3. Optional Rainmeter HUD:
    - make to also download `rainmeterTemplate.ini` and put it in same folder as `t3invo.ahk`
    - Close Rainmeter before starting the `.ahk` script.
4. Run the script using AutoHotkey.
5. Open Tribes 3 and jump into a game.
6. Use the defined hotkeys to switch loadouts or enable/disable the script.

## Notes

- Ensure the hotkeys you define are not already bound in-game.
- If using the weapon swap feature, be aware that changing loadouts manually may require resetting the script state.
- If you are not seeing loadouts change it's probably a `SCREEN_SIZE` issue, make sure you set it to your monitor size. If need be adjust the `SCREEN_RESOLUTION_MAP`.

## Thanks!

- This script was based on an earlier `.ahk` script being shared in the Tribes 3 community. 
= Shoutout to "JimChrist" and those who provided the original layout / clicking concept used in this script.
- "Mexico" for pushing me to add the Rainmeter HUD and helping test
- "Filo" for helping test