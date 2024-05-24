#Requires AutoHotkey v2.0
; VERSION 0.8

; ##### CONFIG AREA (EDIT ME) #####

; # SET CHANGE INVO KEY
KEY_CHANGE_LOADOUT := "c"

; # SET SCREEN SIZE (1080, 1440)
SCREEN_SIZE := 1080
; SCREEN_SIZE := 1440

; # KEY BINDING TO ENABLE OR DISABLE SCRIPT
KEY_ENABLED := "^k"

; # SHOW TOAST WHEN SCRIPT IS TURNED ON AND OFF?
NOTIFY_ENABLED := true

; # SHOW TOAST WHEN INVENTORY IS APPLIED VIA HOTKEY?
NOTIFY_INVENTORY := true 

; # ENABLE Rainmeter HUD?
ENABLE_RAINMETER := true

; # Rainmeter default install location, modify if yours is different
PATH_RAINMETER := "C:\Progra~1\Rainmeter\Rainmeter.exe"
PATH_RAINMETER_SKINS := EnvGet("USERPROFILE") "\Documents\Rainmeter\Skins\"
PATH_RAINMETER_INI := "illustro\Tribes"
if not FileExist(PATH_RAINMETER)
    ENABLE_RAINMETER := false

; # INVENTORY LOADOUT HOTKEYS

;   HotKey = Keyboard Key (make sure not already bound in game, try "F1" ...)
;
;   Loadout = [class, w1, w2, w3, belt, pack]
;
;       class: "pathfinder", "sentinel", "raider", "technician", "doombringer", "juggernaut"
;       w1: "spinfusor", "bolt", "thumper", "plasma"
;       w2: "chain", "phase", "grenade", "nova", "mortar", "gladiator", "plasma"
;       w3: "sparrow", "shotgun", "nova", "shocklance"
;       belt: "explosive", "chaff", "smoke", "impact", "sticky", "ap", "frag", "disc", "mine"
;       pack: "blink", "thrust", "stealth", "turret", "shield", "phase", "dome", "regen", "forcefield"
;
;   Inventory = {
;       [HotKey]: Loadout | Loadout[]
;   }
;

INVENTORY := Map(
    "2", [
        ["pathfinder", "spinfusor", "chain", "shotgun", "explosive", "thrust"],
        ["pathfinder", "spinfusor", "chain", "shotgun", "explosive", "blink"],
    ],
    "3", [
        ["sentinel", "spinfusor", "chain", "shotgun", "impact", "blink"],
        ["sentinel", "spinfusor", "chain", "shotgun", "impact", "thrust"],
    ],
    "4", ["raider", "spinfusor", "chain", "shotgun", "ap", "shield"],
    "5", ["technician", "spinfusor", "chain", "shotgun", "ap", "turret"],
    "6", ["doombringer", "spinfusor", "mortar", "shotgun", "disc", "shield"],
    "7", ["juggernaut", "spinfusor", "chain", "shotgun", "disc", "forcefield"],
)

; # EXPERIMENTAL! weapon swap: switch between two weapons
ENABLE_WEAPON_SWAP := false
; 	Note! use key bindings you don't normally press to allow the swap button to be all you need
KEY_WEAPON_SWAP := "q"
; 	Note! if you changed loadout without using this script or press one of the weapon keys directly, it 
;		might throw off STATE and you will have to press the swap button again to get back on track
KEY_WEAPON_1 := "p"
KEY_WEAPON_2 := "o"


; # ends config editing area!


; ##### DEFINITIONS #####


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
            x: [1450, 1650, 1800],
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
        3: ["sparrow", "shotgun", "nova", "shocklance"]
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
        pack: ["shield", "regen"],
    },
    "juggernaut", {
        index: 6,
        weapons: WEAPON_MAP.heavy,
        belt: ["mine", "disc"],
        pack: ["dome", "regen", "forcefield"],
    }
)

; ##### STATE ##### 

LAYOUT := SCREEN_RESOLUTION_MAP[SCREEN_SIZE]

STATE := {
    enabled: true,
    weapon: 1,
    toggleId: -1,
    toggleIndex: 1,
    tip: "",
}

; ##### FUNCTIONS ##### 

hideToast() {
    global STATE, PATH_RAINMETER
    if (STATE.tip != "") {
        ToolTip("")
        STATE.tip := ""
    }
}

setRainmeterText(title, weapons, items) {
    template := FileRead("rainmeterTemplate.ini")
    template := StrReplace(template, "REPLACE_SKIN_PATH", PATH_RAINMETER_SKINS)
    template := StrReplace(template, "REPLACE_TITLE", title)
    template := StrReplace(template, "REPLACE_WEAPONS", weapons)
    template := StrReplace(template, "REPLACE_ITEMS", items)
    
    file := FileOpen(PATH_RAINMETER_SKINS "\" PATH_RAINMETER_INI "\toast.ini", "w")
    file.Write(template)
    file.Close()
}

updateRainmeter(active) {
    global PATH_RAINMETER, PATH_RAINMETER_INI, PATH_RAINMETER_SKINS

    if (PATH_RAINMETER == "") {
        return
    }

    title := StrUpper(active[1])
    weapons := active[2] ", " active[3] ", " active[4] 
    items := active[5] ", " active[6]

    setRainmeterText(title, weapons, items)
    Run(PATH_RAINMETER " !RefreshApp")
}

toast(msg) {
    global STATE, LAYOUT, PATH_RAINMETER    

    if (STATE.tip != "") {
        SetTimer(hideToast, 0)
        hideToast()
    }

    STATE.tip := msg
    ToolTip(msg, LAYOUT.center.x, LAYOUT.center.y)
    SetTimer(hideToast, -2000)
}

indexOf(arr, value) {
    for index, element in arr {
        if (element = value) {
            return index
        }
    }
    return 1
}

stringJoin(arr, delimiter := ", ") {
    joinedString := ""
    for index, value in arr {
        if (index > 1) {
            joinedString .= delimiter
        }
        joinedString .= value
    }
    return joinedString
}

toggleWeapon(arg) {
	global STATE, KEY_WEAPON_, KEY_WEAPON_2
	STATE.weapon := STATE.weapon == 1 ? 2 : 1
	Send(STATE.weapon == 1 ? KEY_WEAPON_1 : KEY_WEAPON_2)
}

toggledLoadout(pressedKey) {
    global STATE, INVENTORY, CLASS_MAP, WEAPON_MAP, KEY_CHANGE_LOADOUT, LAYOUT, NOTIFY_INVENTORY, PATH_RAINMETER

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

    
    ; if (true) {
    ;     updateRainmeter(active)
    ;     return
    ; }

    ; update state
    STATE.toggleId := pressedKey
    STATE.toggleIndex := toggleIndex
	STATE.weapon := 1

    ; show change class menu
    Send KEY_CHANGE_LOADOUT
    Sleep 100

    ; keys & class info for the loadout to be applied
    className := active[1]
    classIndex := CLASS_MAP[className].index
    weapons := CLASS_MAP[className].weapons
    belt := CLASS_MAP[className].belt
    pack := CLASS_MAP[className].pack

    ; select class
    Click LAYOUT.loadout.x, LAYOUT.loadout.y[classIndex]

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
    if (ENABLE_RAINMETER) {
        updateRainmeter(active)
    } else if (NOTIFY_INVENTORY) {
        toast(StrUpper(className) "`n" active[2] ", " active[3] ", " active[4] "`n" active[5] ", " active[6])
    }
}

toggleEnabled(arg) {
	global LOADOUTS, STATE, ENABLE_WEAPON_SWAP, KEY_WEAPON_SWAP, INVENTORY, NOTIFY_ENABLED

	STATE.enabled := !STATE.enabled
	STATE.weapon := 1
	STATE.toggleId := -1
	STATE.toggleIndex := 1
	
	for key in INVENTORY {
		Hotkey(key, STATE.enabled ? "On" : "Off")
	}

	if (ENABLE_WEAPON_SWAP) {
		HotKey(KEY_WEAPON_SWAP, STATE.enabled ? "On" : "Off")
	}

    if (NOTIFY_ENABLED) {
        enableText := STATE.enabled ? "Enabled" : "Disabled"
        toast("Tribes 3 Script: " enableText)
    }
}

; #### HOTKEY BOOTSTRAP #####

if (ENABLE_RAINMETER) {
    setRainmeterText("Tribes 3 Overlay", "Start Tribes", "Select a Loadout")
    Run(PATH_RAINMETER)
    Run(PATH_RAINMETER " !ToggleConfig `"" PATH_RAINMETER_INI "`" `"toast.ini`"")
}

; ##### HOTKEY BOOTSTRAP #####

; invo bindings
for key in INVENTORY {
	Hotkey(key, (arg) => toggledLoadout(arg))
}

; weapon swap
if (ENABLE_WEAPON_SWAP) {
	HotKey(KEY_WEAPON_SWAP, toggleWeapon)
}

; enable & disable
HotKey(KEY_ENABLED, toggleEnabled)