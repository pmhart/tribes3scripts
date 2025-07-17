#Requires AutoHotkey v2.0

ENABLED := true
KEY_ENABLED := "^k"
KEY_CHANGE_LOADOUT := "i"
KEY_CHAT := "v"

ENABLE_STOPWATCH := true
KEY_SHOW_STOPWATCH := "^g"
KEY_RUN_STOPWATCH := "g"

ENABLE_RETICLE := true
KEY_SHOW_RETICLE := "^p"
KEY_RETICLE_TYPE := "-"
KEY_RETICLE_COLOR := "="
KEY_TOAST_CLASS_INFO := "u"
SHOW_RETICLE_ONLOAD  := true
DEFAULT_RETICLE_TYPE_INDEX := 1
DEFAULT_RETICLE_COLOR_INDEX := 1

INVENTORY := Map(
    ; # CAPPER
    "2", [
        ["pathfinder", "spinfusor", "chain", "sparrow", "explosive", "blink"],
        ["pathfinder", "spinfusor", "chain", "sparrow", "explosive", "thrust"],
    ],
    ; # LD
    "3", [
        ["sentinel", "spinfusor", "chain", "sparrow", "impact", "blink"],
        ["sentinel", "spinfusor", "chain", "sparrow", "impact", "thrust"],
        ["sentinel", "spinfusor", "phase", "sparrow", "impact", "blink"],
    ],
    ; # MEDIUM BASE
    "4", ["raider", "plasma", "grenade", "sparrow", "ap", "phase"],
    ; # MEDIUM O
    "5", [
        ["raider", "thumper", "nova", "sparrow", "ap", "shield"],
        ["raider", "spinfusor", "nova", "sparrow", "ap", "shield"],
        ["raider", "spinfusor", "chain", "sparrow", "ap", "shield"]
    ],
    ; # MEDIUM D
    "6",[
        ["technician", "spinfusor", "chain", "sparrow", "ap", "turret"],
        ["technician", "spinfusor", "nova", "sparrow", "ap", "turret"]
    ],
    ; # HEAVY BASE
    "7", ["doombringer", "spinfusor", "mortar", "shotgun", "frag", "dome"],
    ; # HEAVY O
    "8", ["doombringer", "spinfusor", "mortar", "sparrow", "frag", "shield"],
    ; # HOF
    "9", [
        ["juggernaut", "spinfusor", "mortar", "sparrow", "mine", "forcefield"],
        ["juggernaut", "spinfusor", "chain", "sparrow", "mine", "forcefield"]
    ],
)

; ##### HELPERS #####

indexOf(arr, value) {
    for index, element in arr {
        if (element = value) {
            return index
        }
    }
    return 1
}

; ##### INVENTORY CLASS #####

SCREEN_RESOLUTION_MAP := Map(
    ; 1920 x 1080
    1080, {
        loadout: {
            x: 150,
            y: [200, 285, 370, 450, 535, 620],
        },
        weapon: {
            x: [700, 900, 1100, 1300],
            y: [320, 480, 640],
        },
        belt: {
            x: [660, 800, 920],
            y: 800,
        },
        pack: {
            x: [1090, 1230, 1360],
            y: 800,
        },
        submit: {
            x: 875,
            y: 950,
        },
        center: {
            x: 960,
            y: 540,
        }
    },
    ; 2560 x 1440
    1440, {
        loadout: {
            x: 200,
            y: [260, 380, 490, 600, 715, 825],
        },
        weapon: {
            x: [930, 1200, 1480, 1770],
            y: [440, 650, 850],
        },
        belt: {
            x: [875, 1050, 1240],
            y: 1050,
        },
        pack: {
            x: [1450, 1600, 1800],
            y: 1050,
        },
        submit: {
            x: 1160,
            y: 1275,
        },
        center: {
            x: 1280,
            y: 720,
        }
    },
)

LAYOUT := SCREEN_RESOLUTION_MAP[1080]

WEAPON_MAP := {
    light: {
        1: ["spinfusor", "bolt"],
        2: ["chain", "phase"],
        3: ["sparrow", "shotgun", "shocklance"]
    },
    medium: {
        1: ["spinfusor", "thumper", "plasma"],
        2: ["chain", "grenade", "nova"],
        3: ["sparrow", "shotgun", "shocklance"]
    },
    heavy: {
        1: ["spinfusor", "bolt"],
        2: ["chain", "mortar", "gladiator", "plasma"],
        3: ["sparrow", "shotgun", "shocklance"]
    },
}

CLASS_MAP := Map(
    "pathfinder", {
        index: 1,
        weapons: WEAPON_MAP.light,
        belt: ["explosive", "chaff", "smoke"],
        pack: ["blink", "thrust", "stealth"],
    },
    "sentinel", {
        index: 2,
        weapons: WEAPON_MAP.light,
        belt: ["impact", "explosive", "smoke"],
        pack: ["blink", "thrust", "stealth"],
    },
    "raider", {
        index: 3,
        weapons: WEAPON_MAP.medium,
        belt: ["sticky", "ap"],
        pack: ["shield", "phase"],
    },
    "technician", {
        index: 4,
        weapons: WEAPON_MAP.medium,
        belt: ["emp", "ap"],
        pack: ["turret", "shield", "phase"],
    },
    "doombringer", {
        index: 5,
        weapons: WEAPON_MAP.heavy,
        belt: ["frag", "disc"],
        pack: ["dome", "shield", "regen"],
    },
    "juggernaut", {
        index: 6,
        weapons: WEAPON_MAP.heavy,
        belt: ["mine", "disc"],
        pack: ["dome", "shield", "forcefield"],
    }
)

class ReticleGUI {
    __New() {
        this.gui := false

        this.colorIndex := DEFAULT_RETICLE_COLOR_INDEX
        this.colors := ["FF0000", "00FF00", "0000FF", "FFA500", "800080", "FFFF00", "00FFFF", "FFC0CB"]

        circle := DllCall("CreateEllipticRgn", "Int", 0, "Int", 0, "Int", 3, "Int", 3)

        this.crosshairIndex := DEFAULT_RETICLE_TYPE_INDEX
        this.crosshairs := [
            "12-10 13-11 14-12 13-13 12-14 11-13 10-12 11-11 12-10", ; 2
            "14.5-12.5 14.5-13.5 13.5-13.5 13.5-14.5 11.5-14.5 11.5-14.5 11.5-13.5 10.5-13.5 10.5-12.5 10.5-11.5 11.5-11.5 11.5-10.5 12.5-10.5 13.5-10.5 13.5-11.5 14.5-11.5 14.5-12.5",  ; 2.5
            "15-12 15-13 15-14 14-14 14-15 13-15 12-15 11-15 10-15 10-14 9-14 9-13 9-12 9-11 9-10 10-10 10-9 11-9 12-9 13-9 14-10 15-10 15-11 15-12", ; 3
            ; "10-0 10-4 9-5 8-5 7-5 6-7 5-8 5-10 0-9 0-15 5-14 5-16 6-17 7-18 8-19 9-19 10-20 9-25 15-25 14-19 15-19 16-19 17-18 18-17 19-16 19-15 20-14 25-15 25-9 20-10 19-9 19-8 18-7 17-5 16-5 14-5 15-0 10-0 12-9 10-4 9-5 8-5 7-5 6-7 5-8 5-10 9-12 5-14 5-16 6-17 7-18 8-19 9-19 10-20 12-15 14-19 15-19 16-19 17-18 18-17 19-16 19-15 20-14 16-12 20-10 19-9 19-8 18-7 17-5 16-5 14-5 12-9 12-11 13-12 12-13 12-12 12-11 12-9 10-0",
            ; "10-10 7-2 12-2 12-13 13-12 12-11 12-2 18-2 14-10 23-5 23-18 14-14 18-23 7-23 10-14 2-18 2-5 10-10 6-2 5-2 3-3 2-5 2-5 2-18 2-19 3-21 5-23 6-23 18-23 19-23 21-22 23-19 23-18 23-5 23-5 22-3 20-2 19-2 6-2",
            ; "11-16 11-22 9-20 8-19 7-18 6-17 5-16 5-15 4-14 4-10 5-9 5-8 6-7 7-6 8-5 9-4 10-4 11-3 14-3 15-4 16-4 17-5 18-6 19-7 20-8 20-9 21-10 21-14 20-15 20-16 19-17 18-18 17-19 16-20 14-22 14-16 15-17 16-17 17-16 17-15 18-14 18-10 17-9 17-8 16-7 15-7 14-6 11-6 10-7 9-7 8-8 8-9 7-10 7-14 8-15 8-16 9-17 10-17 11-16 11-16 11-12 12-13 12-10 13-11 12-12 12-13 11-12 12-13 11-14 13-14 13-12 14-13 13-14 11-14",
            ; "7-8 12-0 17-8 20-12 24-21 15-21 9-21 0-21 4-12 6-13 3-19 9-19 9-21 15-21 15-19 21-19 18-13 20-12 17-8 15-9 12-4 9-9 7-8",
            ; "12-0 15-0 16-1 17-1 18-2 19-2 20-3 21-4 22-5 22-6 23-7 23-8 24-9 24-15 23-16 23-17 22-18 22-19 21-20 20-21 19-22 18-22 17-23 16-23 15-24 9-24 8-23 7-23 6-22 5-22 4-21 3-20 2-19 2-18 1-17 1-16 0-15 0-9 1-8 1-7 2-6 2-5 3-4 4-3 5-2 6-2 7-1 8-1 9-0 12-0 13-1 13-9 12-9 12-2 9-2 8-3 7-3 6-4 5-4 4-5 4-6 3-7 3-8 2-9 2-12 9-12 9-13 2-13 2-15 3-16 3-17 4-18 4-19 5-20 6-20 7-21 8-21 9-22 12-22 12-15 13-15 13-22 15-22 16-21 17-21 18-20 19-20 20-19 20-18 21-17 21-16 22-15 22-13 15-13 15-12 22-12 22-9 21-8 21-7 20-6 20-5 19-4 18-4 17-3 16-3 15-2 12-2 12-0",
            ; "12-0 15-0 16-1 17-1 18-2 19-2 20-3 21-4 22-5 22-6 23-7 23-8 24-9 24-15 23-16 23-17 22-18 22-19 21-20 20-21 19-22 18-22 17-23 16-23 15-24 9-24 8-23 7-23 6-22 5-22 4-21 3-20 2-19 2-18 1-17 1-16 0-15 0-9 1-8 1-7 2-6 2-5 3-4 4-3 5-2 6-2 7-1 8-1 9-0 12-0 12-2 9-2 8-3 7-3 6-4 4-3 3-4 4-6 3-7 3-8 2-9 2-15 3-16 3-17 4-18 2-19 4-22 6-20 7-21 8-21 9-22 15-22 16-21 17-21 18-20 20-21 21-19 20-18 21-17 21-16 22-15 22-9 21-8 21-7 20-6 21-4 20-3 18-4 17-3 16-3 15-2 12-2 12-0 12-13 13-12 12-11 12-0",
            ; "12-0 15-0 16-1 17-1 18-2 19-2 20-3 21-4 22-5 22-6 23-7 23-8 24-9 24-15 23-16 23-17 22-18 22-19 21-20 20-21 19-22 18-22 17-23 16-23 15-24 9-24 8-23 7-23 6-22 5-22 4-21 3-20 2-19 2-18 1-17 1-16 0-15 0-9 1-8 1-7 2-6 2-5 3-4 4-3 5-2 6-2 7-1 8-1 9-0 12-0 12-2 9-2 8-3 8-6 7-7 7-10 8-10 9-9 9-7 8-6 8-3 7-3 6-4 5-4 4-5 4-6 3-7 3-8 2-9 2-15 3-16 3-17 4-18 4-19 5-20 6-20 7-21 8-21 9-22 12-22 12-16 9-16 8-17 7-17 5-19 4-18 4-17 5-16 6-15 7-14 8-14 9-13 15-13 16-14 17-14 18-15 19-16 20-17 20-18 19-19 18-19 17-17 16-17 15-16 12-16 12-22 15-22 16-21 17-21 18-20 19-20 20-19 20-18 21-17 21-16 22-15 22-9 21-8 21-7 20-6 20-5 19-4 18-4 17-3 16-3 16-7 16-10 17-10 18-9 18-7 17-6 16-7 16-3 15-2 12-2 12-0",
            ; "12-0 15-0 16-1 17-1 18-2 19-2 20-3 21-4 22-5 22-6 23-7 23-8 24-9 24-15 23-16 23-17 22-18 22-19 21-20 20-21 19-22 18-22 17-23 16-23 15-24 9-24 8-23 7-23 6-22 5-22 4-21 3-20 2-19 2-18 1-17 1-16 0-15 0-9 1-8 1-7 2-6 2-5 3-4 4-3 5-2 6-2 7-1 8-1 9-0 12-0 12-2 9-2 8-3 7-3 6-4 5-4 4-5 4-6 3-7 3-8 2-9 2-15 3-16 3-17 4-18 4-19 5-20 6-20 7-21 8-21 8-20 8-16 4-16 4-17 7-20 8-20 8-21 9-22 15-22 16-21 16-20 16-16 18-16 20-16 20-17 16-20 16-21 17-21 18-20 19-20 20-19 20-18 21-17 21-16 22-15 22-9 21-8 21-7 20-6 20-5 19-4 18-4 17-3 16-3 15-3 9-3 12-6 15-3 15-2 12-2 12-0",
            ; "12-0 25-0 25-25 0-25 0-0 9-0 7-2 2-2 2-7 0-9 0-15 2-17 2-23 7-23 9-25 16-25 18-23 23-23 23-17 25-15 25-9 23-7 23-2 17-2 15-0 12-0 12-3 12-11 11-11 11-12 3-12 3-13 11-13 11-14 12-14 12-22 13-22 13-14 14-14 14-13 22-13 22-12 14-12 14-11 13-11 13-3 12-3 12-0"
        ]
    }

    Draw() {
        if (this.gui != false) {
            this.gui.BackColor := this.colors[this.colorIndex]
            WinSetRegion(this.crosshairs[this.crosshairIndex], this.gui.Hwnd)
        }    
    }

    Show() {
        if (this.gui != false) {
            return
        }

        this.gui := Gui()
        this.gui.Opt("+LastFound")
        this.gui.Opt("+AlwaysOnTop")
        this.gui.Opt("-Caption")
        this.gui.Opt("+Owner")
        this.gui.MarginX := 0
        this.gui.MarginY := 0

        size := 25 ; Maximum canvas size of X-Y values for crosshair
        screenWidth := SysGet(0)
        screenHeight := SysGet(1)
        x := screenWidth//2-(size//2)
        y := screenHeight//2-(size//2)
        this.gui.Show("w" . size . " h" . size . " x" . x . " y" . y . " NA")  
        WinSetStyle("+E0x80020", this.gui.Hwnd) ; Extended style, makes the window ignore the mous cursor

        this.Draw()
    }

    Hide() {
        this.crosshairIndex := DEFAULT_RETICLE_TYPE_INDEX
        this.colorIndex := DEFAULT_RETICLE_COLOR_INDEX

        if (this.gui != false) {
            this.gui.Destroy()
            this.gui := false
        }
    }

    ToggleDisplay() {
        if (this.gui == false) {
            this.Show()
        } else {
            this.HIde()
        }
    }

    ToggleCrosshair() {
        if (this.gui == false) {
            return
        }

        this.crosshairIndex += 1
        if (this.crosshairIndex > this.crosshairs.Length) {
            this.crosshairIndex := 1
        }

        this.Draw()
    }

    ToggleColor() {
        this.colorIndex += 1
        if (this.colorIndex > this.colors.Length) {
            this.colorIndex := 1
        }

        this.Draw()
    }
}

class StopwatchGUI {
    __New() {
        this.interval := 1000
        this.gui := false
        this.running := false
        this.seconds := 0
        this.timer := ObjBindMethod(this, "Tick")
    }

    Reset() {
        this.seconds := 0
        if (this.gui != false) {
            this.gui["TimeText"].Value := "00:00"
        }
    }

    Stop() {
        this.Reset()
        this.running := false
        SetTimer this.timer, 0
    }

    Start() {
        this.Reset()   
        this.running := true
        SetTimer this.timer, this.interval
    }

    Close() {
        this.Stop()
        Hotkey(KEY_RUN_STOPWATCH, "Off")    

        if (this.gui != false) {
            this.gui.Destroy()
            this.gui := false
        }
    }

    ToggleGUI() {
        if (this.gui != false) {
            this.Close()
            return
        }

        screenWidth := SysGet(0)
        screenHeight := SysGet(1)
        w := 165
        h := 69
        x := screenWidth - w - 16
        y := screenHeight//2 - h//2

        this.gui := Gui()
        this.gui.Opt("+LastFound")
        this.gui.Opt("+AlwaysOnTop")
        this.gui.Add("Text", "x67 y22 w60 h20 vTimeText", "00:00")
        this.gui.OnEvent("Close", (arg) => this.Close())
        this.gui.Show("w" . w . " h" . h . " x" . x . " y" . y)

        Hotkey(KEY_RUN_STOPWATCH, "On")
    }

    ToggleRunning() {
        if (this.gui == false) {
            return
        }

        if (this.running) {
            this.Stop()
        } else {
            this.Start()
        }
    }

    FormatSeconds(seconds) {
        time := 19990101  ; *Midnight* of an arbitrary date.
        time := DateAdd(time, seconds, "Seconds")

        if (seconds < 3600) {
            ; hours ...
            return FormatTime(time, "mm:ss")
        }

        return seconds//3600 ":" FormatTime(time, "mm:ss")
    }

    Tick() {
        if (this.gui == false) {
            this.Close()
        }

        this.seconds += 1
        this.gui["TimeText"].Value := this.FormatSeconds(this.seconds)
    }
}

STATE := {
    enabled: true,
    weapon: 1,
    toggleId: -1,
    toggleIndex: 1,
    tip: "",
    info: "",
}

STOPWATCH := StopwatchGUI()
RETICLE := ReticleGUI()

hideToast() {
    global STATE
    if (STATE.tip != "") {
        ToolTip("")
        STATE.tip := ""
    }
}

toast(msg) {
    global STATE, LAYOUT

    if (STATE.tip != "") {
        SetTimer(hideToast, 0)
        hideToast()
    }

    STATE.tip := msg
    ToolTip(msg, 100, 100)
    SetTimer(hideToast, -2000)
}

toastInfo(arg) {
    global STATE
    toast(STATE.info)    
}

toggledLoadout(pressedKey) {
    global STATE, INVENTORY, CLASS_MAP, WEAPON_MAP, KEY_CHANGE_LOADOUT, LAYOUT

    loadouts := INVENTORY[pressedKey]
	if (!loadouts) {
		return
	}

    ; determine toggleIndex & active loadout config
    toggleIndex := 1
    if (Type(loadouts[1]) == "Array") {
        if (STATE.toggleId == pressedKey) {
            nextIndex := STATE.toggleIndex + 1 
            toggleIndex := nextIndex > loadouts.Length ? 1 : nextIndex
        }
        active := loadouts[toggleIndex]
    }else {
        active := loadouts
    }

    ; get active setup for toggleIndex
    if(!active) {
        return
    }

    ; update state
    STATE.toggleId := pressedKey
    STATE.toggleIndex := toggleIndex
	STATE.weapon := 1

    ; show change class menu
    Send KEY_CHANGE_LOADOUT
    Sleep 200

    ; keys & class info for the loadout to be applied
    className := active[1]
    classIndex := CLASS_MAP[className].index
    weapons := CLASS_MAP[className].weapons
    belt := CLASS_MAP[className].belt
    pack := CLASS_MAP[className].pack
    ; STATE.info := className "`n" active[2] ", " active[3] ", " active[4] "`n" active[5] ", " active[6]
    STATE.info := className ", " active[2] ", " active[6]

    ; select class
    Click LAYOUT.loadout.x, LAYOUT.loadout.y[classIndex]
    Sleep 100

    ; select first weapon
    indexW1x := indexOf(weapons.1, active[2])
    Click LAYOUT.weapon.x[indexW1x], LAYOUT.weapon.y[1]

    ; select second weapon
    indexW2x := indexOf(weapons.2, active[3])
    Click LAYOUT.weapon.x[indexW2x], LAYOUT.weapon.y[2]
    
    ; select third weapon
    indexW3x := indexOf(weapons.3, active[4])
    Click LAYOUT.weapon.x[indexW3x], LAYOUT.weapon.y[3]
    
    ; select belt
    indexBeltx := indexOf(belt, active[5])
    Click LAYOUT.belt.x[indexBeltx], LAYOUT.belt.y
    
    ; select pack
    indexPackx := indexOf(pack, active[6])
    Click LAYOUT.pack.x[indexPackx], LAYOUT.pack.y

    ; click to apply changes
    Click LAYOUT.submit.x, LAYOUT.submit.y

    ; notify
    toast(STATE.info)
}

; ##### TOGGLE ENABLE #####

toggleEnabled(arg) {
    global STATE
    global INVENTORY
    global ENABLE_STOPWATCH
    global ENABLE_RETICLE
    global RETICLE

    STATE.enabled := !STATE.enabled

    ; Hotkey(KEY_TOAST_CLASS_INFO, STATE.enabled ? "On" : "Off")

    for key in INVENTORY {
        Hotkey(key, STATE.enabled ? "On" : "Off")
    }

    if (ENABLE_STOPWATCH) {
        Hotkey(KEY_SHOW_STOPWATCH, STATE.enabled ? "On" : "Off")
        Hotkey(KEY_RUN_STOPWATCH, "Off")
    }

    if (ENABLE_RETICLE) {

        Hotkey(KEY_SHOW_RETICLE, STATE.enabled ? "On" : "Off")
        Hotkey(KEY_RETICLE_TYPE, STATE.enabled ? "On" : "Off")
        Hotkey(KEY_RETICLE_COLOR, STATE.enabled ? "On" : "Off")

        if (STATE.enabled && SHOW_RETICLE_ONLOAD) {
            RETICLE.Show()
        }else {
            RETICLE.Hide()
        }
    }

    Hotkey(KEY_TOAST_CLASS_INFO, STATE.enabled ? "On" : "Off")

    toast(STATE.enabled ? "ENABLED" : "DISABLED")
       
}


for key in INVENTORY {
	Hotkey(key, (arg) => toggledLoadout(arg))
}

HotKey(KEY_ENABLED, toggleEnabled)
Hotkey(KEY_TOAST_CLASS_INFO, toastInfo)

if (ENABLE_STOPWATCH) {
    Hotkey(KEY_SHOW_STOPWATCH, (arg) => STOPWATCH.ToggleGUI())
    Hotkey(KEY_RUN_STOPWATCH, (arg) => STOPWATCH.ToggleRunning())
    Hotkey(KEY_RUN_STOPWATCH, "Off")
}

if (ENABLE_RETICLE) {
    Hotkey(KEY_SHOW_RETICLE, (arg) => RETICLE.ToggleDisplay())
    Hotkey(KEY_RETICLE_TYPE, (arg) => RETICLE.ToggleCrosshair())
    Hotkey(KEY_RETICLE_COLOR, (arg) => RETICLE.ToggleColor())

    if (SHOW_RETICLE_ONLOAD) {
        RETICLE.ToggleDisplay()
    }
}   