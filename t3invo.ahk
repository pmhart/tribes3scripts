#Requires AutoHotkey v2.0
; VERSION 0.8

; ##### CONFIG AREA (EDIT ME) #####

; # SET CHANGE INVO KEY
KEY_CHANGE_LOADOUT := "c"

; # SET SCREEN SIZE (1080, 1440)
SCREEN_SIZE := 1440

; # ENABLE OR DISABLE SCRIPT
KEY_ENABLED := "^k"

; INVENTORY LOADOUT HOTKEYS
;
; 	{
; 		key: "{ENTER KEYBOARD KEY HERE, CAN INCLUDE ^ for ctrl etc}",
; 		loadouts: [
; 			[weightKey, sideKey, [w1, w2, w3, belt, pack]]
;			// ... add more here so pressing the same key cycles if you would like
; 		]
; 	}
;
INVENTORY := [
	{
		key: "2",
		loadouts: [
			["light", "offense", ["spinfusor", "chain", "shotgun", "explosive", "thrust"]],
			["light", "offense", ["spinfusor", "chain", "shotgun", "explosive", "blink"]],
		]
	},
	{
		key: "3",
		loadouts: [
			["light", "defense", ["spinfusor", "chain", "shotgun", "impact", "thrust"]],
			["light", "defense", ["spinfusor", "chain", "shotgun", "impact", "blink"]],
		]
	},
	{
		key: "4",
		loadouts: [
			["medium", "offense", ["spinfusor", "chain", "shotgun", "ap", "shield"]]
		]
	},
	{
		key: "5",
		loadouts: [
			["medium", "defense", ["spinfusor", "chain", "shotgun", "ap", "turret"]]
		]
	},
	{
		key: "6",
		loadouts: [
			["heavy", "offense", ["spinfusor", "mortar", "shotgun", "disc", "shield"]]
		],
	},
	{
		key: "7",
		loadouts: [
			["heavy", "defense", ["spinfusor", "chain", "shotgun", "disc", "forcefield"]]
		],
	},
]

; weapon swap: switch between two weapons
ENABLE_WEAPON_SWAP := true
; 	Note! use key bindings you don't normally press to allow the swap button to be all you need
KEY_WEAPON_SWAP := "q"
; 	Note! if you changed loadout without using this script or press one of the weapon keys directly, it 
;		might throw off STATE and you will have to press the swap button again to get back on track
KEY_WEAPON_1 := "p"
KEY_WEAPON_2 := "o"


; # ends config editing area!


; ##### DEFS #####

RESOLUTION := Map(
    1080, {
        classx: 150,
        classy: [200, 285, 370, 450, 535, 620],

        weaponx: [700, 900, 1100, 1300],
        weapon1y: 320,
        weapon2y: 480,
        weapon3y: 640,

        beltx: [660, 800, 920],
        belty: 800,

        packx: [1090, 1230, 1360],
        packy: 800,

        selectx: 875,
        selecty: 950
    },
    1440, {
        classx: 200,
        classy: [260, 380, 490, 600, 715, 825],

        weaponx: [930, 1200, 1480, 1770],
        weapon1y: 440,
        weapon2y: 650,
        weapon3y: 850,

        beltx: [875, 1050, 1240],
        belty: 1050,

        packx: [1450, 1650, 1800],
        packy: 1050,

        selectx: 1160,
        selecty: 1275
    },
)

LOADOUT := Map(
    "light", Map(
        "weapon1", ["spinfusor", "bolt"],
        "weapon2", ["chain", "phase"],
        "weapon3", ["sparrow", "shotgun", "shocklance"],
        "offense", {
            id: 1,
            belt: ["explosive", "chaff", "smoke"],
            pack: ["blink", "thrust", "stealth"],
        },
        "defense", {
            id: 2,
            belt: ["impact", "explosive", "smoke"],
            pack: ["blink", "thrust", "stealth"],
        },
    ),
    "medium", Map(
        "weapon1", ["spinfusor", "thumper", "plasma"],
        "weapon2", ["chain", "grenade", "nova"],
        "weapon3", ["sparrow", "shotgun", "shocklance"],
        "offense", {
            id: 3,
            belt: ["sticky", "ap"],
            pack: ["shield", "phase"],
        },
        "defense", {
            id: 4,
            belt: ["emp", "ap"],
            pack: ["turret", "shield", "phase"],
        },
    ),
    "heavy", Map(
        "weapon1", ["spinfusor", "bolt"],
        "weapon2", ["chain", "mortar", "gladiator", "plasma"],
        "weapon3", ["sparrow", "shotgun", "nova", "shocklance"],
        "offense", {
            id: 5,
            belt: ["frag", "disc"],
            pack: ["shield", "regen"],
        },
        "defense", {
            id: 6,
            belt: ["mine", "disc"],
            pack: ["dome", "regen", "forcefield"],
        },
    )
)

; ##### STATE ##### 

LAYOUT := RESOLUTION[SCREEN_SIZE]

STATE := {
	enabled: true,
	weapon: 1,
	toggleId: -1,
    toggleIndex: 1,
}

; ##### FUNCTIONS ##### 

indexOf(arr, value) {
    for index, element in arr {
        if (element = value) {
            return index
        }
    }
    return 1
}

configForHotkey(key) {
    global INVENTORY
	for index, element in INVENTORY {
        if (element.key = key) {
            return element
        }
    }
}

toggleWeapon(arg) {
	global STATE, KEY_WEAPON_, KEY_WEAPON_2
	STATE.weapon := STATE.weapon == 1 ? 2 : 1
	Send(STATE.weapon == 1 ? KEY_WEAPON_1 : KEY_WEAPON_2)
}

toggledLoadout(key) {
    global STATE, INVENTORY, LOADOUT, KEY_CHANGE_LOADOUT, LAYOUT

	config := configForHotkey(key)
	if (!config) {
		return
	}

	toggleId := config.key
	loadouts := config.loadouts
	hasMultiple := loadouts.length > 1

    if (STATE.toggleId == toggleId and hasMultiple) {
        STATE.toggleIndex := STATE.toggleIndex + 1 
    } else {
        STATE.toggleIndex := 1
    }

	STATE.weapon := 1
    STATE.toggleId := toggleId
    if (STATE.toggleIndex > loadouts.Length) {
        STATE.toggleIndex := 1
    }  

    active := loadouts[STATE.toggleIndex]
    weight := LOADOUT[active[1]]
    side := weight[active[2]]
	selections := active[3]

	; indexes that lead to x positions of selections
    w1 := indexOf(weight["weapon1"], selections[1])
    w2 := indexOf(weight["weapon2"], selections[2])
    w3 := indexOf(weight["weapon3"], selections[3])
    belt := indexOf(side.belt, selections[4])
    pack := indexOf(side.pack, selections[5])

	Send KEY_CHANGE_LOADOUT
    Sleep 100
    Click LAYOUT.classx, LAYOUT.classy[side.id]
    Click LAYOUT.weaponx[w1], LAYOUT.weapon1y
    Click LAYOUT.weaponx[w2], LAYOUT.weapon2y
    Click LAYOUT.weaponx[w3], LAYOUT.weapon3y
    Click LAYOUT.beltx[belt], LAYOUT.belty
    Click LAYOUT.packx[pack], LAYOUT.packy
    Click LAYOUT.selectx, LAYOUT.selecty
}

toggleEnabled(arg) {
	global LOADOUTS, STATE, ENABLE_WEAPON_SWAP, KEY_WEAPON_SWAP, INVENTORY

	STATE.enabled := !STATE.enabled
	STATE.weapon := 1
	STATE.toggleId := -1
	STATE.toggleIndex := 1
	
	for index, value in INVENTORY {
		Hotkey(value.key, STATE.enabled ? "On" : "Off")
	}

	if (ENABLE_WEAPON_SWAP) {
		HotKey(KEY_WEAPON_SWAP, STATE.enabled ? "On" : "Off")
	}
}

; ##### HOTKEY BOOTSTRAP #####

; invo bindings
for index, value in INVENTORY {
	Hotkey(value.key, (arg) => toggledLoadout(arg))
}

; weapon swap
if (ENABLE_WEAPON_SWAP) {
	HotKey(KEY_WEAPON_SWAP, toggleWeapon)
}

; enable & disable
HotKey(KEY_ENABLED, toggleEnabled)