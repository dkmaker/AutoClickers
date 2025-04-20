#Requires AutoHotkey v2.0
#SingleInstance
InstallMouseHook()          ; activate mouse hook for precise tracking
InstallKeybdHook()          ; activate keyboard hook
SendMode("Input")
SetWorkingDir(A_ScriptDir)

; ────────────────────────────────────────────────────────────────
; CONFIGURATION
; ────────────────────────────────────────────────────────────────
WaitTime  := 5000             ; ms inactivity before automation starts (5 s)
TargetWin := "Roblox"         ; part of window title that identifies the game
Debug     := true             ; HUD on/off (F10 toggles)

ClickMin  := 100              ; click interval 0.10-0.30 s
ClickMax  := 300
MoveMin   := 60000            ; movement 60-90 s
MoveMax   := 90000
MouseThresh := 10             ; px mouse movement that stops automation

; Click blackout configuration
BlackoutOffset := 100         ; ms offset for weapon switching click blackout

; Key press durations
MovementKeyHoldMin := 400     ; Movement keys (WASD) hold time (ms)
MovementKeyHoldMax := 800
WeaponKeyHoldMin := 50        ; Weapon keys (1,2) hold time (ms)
WeaponKeyHoldMax := 100
KeyPauseDuration := 50        ; Pause between key actions (ms)

; ────────────────────────────────────────────────────────────────
; STATE MACHINE CONSTANTS
; ────────────────────────────────────────────────────────────────
STATE_DISABLED := 0
STATE_ARMED := 1
STATE_RUNNING := 2

; ────────────────────────────────────────────────────────────────
; STATE VARIABLES
; ────────────────────────────────────────────────────────────────
CurrentState := STATE_DISABLED
NextClick := 0                ; Timestamp when next click should occur
NextMove := 0                 ; Timestamp when next movement should occur
LastMouseX := 0
LastMouseY := 0
HudVisible := false
LastStateChange := A_TickCount
ActiveKey := ""               ; Tracks currently pressed key, if any

; Click tracking for average calculation
ClickIntervals := []          ; Array to store last 10 click intervals
LastClickTime := 0            ; Timestamp of the last click
AvgClickInterval := 0         ; Average click interval in ms
TotalClicks := 0              ; Counter for total clicks performed
ClicksEnabled := true         ; Boolean flag to control if clicks are allowed

; Movement sequence variables
KeySequence := []             ; Array to hold sequence of keys to press
KeyActionTime := 0            ; Timestamp for next key action
KeyActionIndex := 1           ; Current index in key sequence
KeyActionState := 0           ; 0=idle, 1=key down, 2=key waiting, 3=key up, 4=post-sequence delay
KeyHoldDuration := 0          ; How long to hold the current key

; ────────────────────────────────────────────────────────────────
; MAIN TIMER
; ────────────────────────────────────────────────────────────────
; On script exit, ensure all keys are released
OnExit((*) => ReleaseAllKeys())

SetTimer(StateMachine, 50)    ; Run state machine every 50ms
SetTimer(HUD, 250)            ; HUD refresh 4×/s
Return

; ────────────────────────────────────────────────────────────────
; STATE MACHINE
; ────────────────────────────────────────────────────────────────
StateMachine() {
    global CurrentState, LastStateChange
    
    ; Get current mouse position for tracking
    MouseGetPos(&currentMouseX, &currentMouseY)
    
    ; Execute current state's behavior
    switch CurrentState {
        case STATE_DISABLED:
            HandleDisabledState()
        case STATE_ARMED:
            HandleArmedState(currentMouseX, currentMouseY)
        case STATE_RUNNING:
            HandleRunningState(currentMouseX, currentMouseY)
    }
}

; ────────────────────────────────────────────────────────────────
; STATE HANDLERS
; ────────────────────────────────────────────────────────────────
HandleDisabledState() {
    ; Nothing to do in disabled state - just waiting for F9 to arm
}

HandleArmedState(currentMouseX, currentMouseY) {
    global WaitTime, TargetWin, LastMouseX, LastMouseY, LastStateChange
    
    ; First check if window is not active - transition to DISABLED
    if (!WinActive(TargetWin)) {
        TransitionToState(STATE_DISABLED)
        return
    }
    
    ; Check if we've been in ARMED state for more than 15 seconds
    if (A_TickCount - LastStateChange > 15000) {
        TransitionToState(STATE_DISABLED)
        return
    }
    
    ; Update mouse position tracking
    LastMouseX := currentMouseX
    LastMouseY := currentMouseY
    
    ; Check if we should transition to RUNNING state
    if (A_TimeIdlePhysical >= WaitTime) {
        TransitionToState(STATE_RUNNING)
    }
}

HandleRunningState(currentMouseX, currentMouseY) {
    global TargetWin, MouseThresh, LastMouseX, LastMouseY
    global NextClick, NextMove, ClickMin, ClickMax, MoveMin, MoveMax
    global LastClickTime, ClickIntervals, AvgClickInterval, KeyActionState
    global TotalClicks, ClicksEnabled
    
    ; Update sequence time for tracking only
    static lastSequenceTime := 0
    if (KeyActionState != 0) {
        ; We're in a sequence
        lastSequenceTime := A_TickCount
    }
    
    ; Check if window lost focus - transition to DISABLED
    if (!WinActive(TargetWin)) {
        TransitionToState(STATE_DISABLED)
        return
    }
    
    ; Check for user input - transition to ARMED (not DISABLED)
    if (A_TimeIdlePhysical < 500 || 
        Abs(currentMouseX - LastMouseX) > MouseThresh || 
        Abs(currentMouseY - LastMouseY) > MouseThresh) {
        TransitionToState(STATE_ARMED)
        return
    }
    
    ; Update mouse position tracking
    LastMouseX := currentMouseX
    LastMouseY := currentMouseY
    
    now := A_TickCount
    
    ; Time for a click?
    if (now >= NextClick) {
        ; Only click if clicks are enabled
        if (ClicksEnabled) {
            ; Track click interval for average calculation
            if (LastClickTime > 0) {
                interval := now - LastClickTime
                ClickIntervals.Push(interval)
                ; Keep only last 10 intervals
                if (ClickIntervals.Length > 10)
                    ClickIntervals.RemoveAt(1)
                ; Calculate average
                sum := 0
                for i in ClickIntervals
                    sum += i
                AvgClickInterval := Round(sum / ClickIntervals.Length)
            }
            
            Click
            TotalClicks++     ; Increment click counter
            LastClickTime := now
        }
        
        ; Schedule next click regardless (to avoid click buildup)
        NextClick := now + Random(ClickMin, ClickMax)
    }
    
    ; Time for movement?
    if (now >= NextMove && KeyActionState == 0) {
        ; Only start new movement if we're not in the middle of a sequence
        StartMovementSequence()
        NextMove := now + Random(MoveMin, MoveMax)
    }
    
    ; Process any ongoing key sequence
    ProcessKeySequence()
}

; ────────────────────────────────────────────────────────────────
; STATE TRANSITIONS
; ────────────────────────────────────────────────────────────────
TransitionToState(newState) {
    global CurrentState, LastStateChange
    global NextClick, NextMove, ClickMin, ClickMax, MoveMin, MoveMax
    
    ; Don't transition if already in this state
    if (newState = CurrentState)
        return
        
    ; Handle exit actions for current state
    switch CurrentState {
        case STATE_RUNNING:
            ReleaseAllKeys()  ; Safety: release any pressed keys
    }
    
    ; Update state
    CurrentState := newState
    LastStateChange := A_TickCount
    
    ; Handle entry actions for new state
    switch newState {
        case STATE_DISABLED:
            ; Reset all variables when entering disabled state
            NextClick := 0
            NextMove := 0
            KeySequence := []
            KeyActionState := 0
            KeyActionIndex := 1
            KeyActionTime := 0
            KeyHoldDuration := 0
            ActiveKey := ""
            ClickIntervals := []
            LastClickTime := 0
            AvgClickInterval := 0
            TotalClicks := 0   ; Reset click counter
            ClicksEnabled := true ; Ensure clicks are enabled
            ReleaseAllKeys()  ; Extra safety: release keys when entering disabled
            
        case STATE_ARMED:
            ; Nothing special to initialize
            
        case STATE_RUNNING:
            ; Initialize timers for next actions
            now := A_TickCount
            NextClick := now + Random(ClickMin, ClickMax)
            NextMove := now + Random(MoveMin, MoveMax)
            
            ; Reset click tracking variables for fresh average calculation
            ClickIntervals := []
            LastClickTime := 0
            AvgClickInterval := 0
            
            ; Ensure clicks are initially enabled
            ClicksEnabled := true
            
            ; Start with weapon switching sequence to ensure weapon 1 is selected
            CreateWeaponSwitchSequence()
            
            ; Update mouse position at start
            MouseGetPos(&LastMouseX, &LastMouseY)
    }
}

; ────────────────────────────────────────────────────────────────
; KEY MANAGEMENT
; ────────────────────────────────────────────────────────────────
ReleaseAllKeys() {
    global ActiveKey, KeySequence, KeyActionState, KeyActionIndex
    
    ; Release all possible keys that might be down
    keys := ["w", "a", "s", "d", "1", "2"]
    for k in keys {
        Send "{" k " up}"
    }
    
    ; Reset key sequence state
    KeySequence := []
    KeyActionState := 0
    KeyActionIndex := 1
    ActiveKey := ""
}


CreateWeaponSwitchSequence() {
    global KeySequence, KeyActionState, KeyActionIndex, KeyActionTime
    global BlackoutOffset
    
    ; Only start if we're not already in a sequence
    if (KeyActionState != 0)
        return
    
    ; Create a sequence for weapon switching with blackout control
    KeySequence := []
    
    ; Disable clicks before weapon switching
    KeySequence.Push(["disable_clicks", "", false])
    
    ; Add delay before pressing 2 (using the BlackoutOffset)
    KeySequence.Push(["delay", BlackoutOffset, false])
    
    ; Weapon switching sequence
    KeySequence.Push(["2", "down", false])
    KeySequence.Push(["2", "up", false])
    KeySequence.Push(["1", "down", false])
    KeySequence.Push(["1", "up", false])
    
    ; Add delay after releasing 1 (using the BlackoutOffset)
    KeySequence.Push(["delay", BlackoutOffset, false])
    
    ; Re-enable clicks
    KeySequence.Push(["enable_clicks", "", true])  ; Mark this as the last action
    
    ; Initialize sequence processing
    KeyActionIndex := 1
    KeyActionState := 1 ; Ready to process first action
    KeyActionTime := A_TickCount ; Start immediately
}

StartMovementSequence() {
    global KeySequence, KeyActionState, KeyActionIndex, KeyActionTime
    global BlackoutOffset
    
    ; Only start if we're not already in a sequence
    if (KeyActionState != 0)
        return
        
    ; Create the movement sequence
    KeySequence := []
    
    ; Add movement keys in random order
    movementKeys := ["w", "a", "s", "d"]
    ShuffleArray(movementKeys)
    
    ; Add each movement key to the sequence
    for k in movementKeys {
        ; Each key gets two actions: down and up
        KeySequence.Push([k, "down", false])
        KeySequence.Push([k, "up", false])
    }
    
    ; Disable clicks before weapon switching
    KeySequence.Push(["disable_clicks", "", false])
    
    ; Add delay before pressing 2 (using the BlackoutOffset)
    KeySequence.Push(["delay", BlackoutOffset, false])
    
    ; Weapon switching sequence
    KeySequence.Push(["2", "down", false])
    KeySequence.Push(["2", "up", false])
    KeySequence.Push(["1", "down", false])
    KeySequence.Push(["1", "up", false])
    
    ; Add delay after releasing 1 (using the BlackoutOffset)
    KeySequence.Push(["delay", BlackoutOffset, false])
    
    ; Re-enable clicks
    KeySequence.Push(["enable_clicks", "", true])  ; Mark this as the last action
    
    ; Initialize sequence processing
    KeyActionIndex := 1
    KeyActionState := 1 ; Ready to process first action
    KeyActionTime := A_TickCount ; Start immediately
}

ProcessKeySequence() {
    global KeySequence, KeyActionIndex, KeyActionState, KeyActionTime
    global ActiveKey, KeyHoldDuration, BlackoutOffset
    global ClicksEnabled, KeyPauseDuration
    global WeaponKeyHoldMin, WeaponKeyHoldMax, MovementKeyHoldMin, MovementKeyHoldMax
    
    ; If no active sequence or not time for next action yet, return
    if (KeyActionState == 0 || A_TickCount < KeyActionTime)
        return
        
    ; Process the current action based on state
    switch KeyActionState {
        case 1: ; Key down or special action
            if (KeyActionIndex <= KeySequence.Length) {
                action := KeySequence[KeyActionIndex]
                key := action[1]
                
                ; Handle special actions
                if (key == "disable_clicks") {
                    ; Disable clicks
                    ClicksEnabled := false
                    KeyActionTime := A_TickCount + KeyPauseDuration
                    KeyActionIndex++
                    return
                }
                else if (key == "enable_clicks") {
                    ; Enable clicks
                    ClicksEnabled := true
                    isLastInSequence := action.Length > 2 ? action[3] : false
                    
                    if (isLastInSequence) {
                        ; Sequence complete
                        KeyActionState := 0
                        KeyActionIndex := 1
                        KeySequence := []
                    } else {
                        KeyActionTime := A_TickCount + KeyPauseDuration
                        KeyActionIndex++
                    }
                    return
                }
                else if (key == "delay") {
                    ; Just wait for the specified time
                    delayTime := action[2]
                    KeyActionTime := A_TickCount + delayTime
                    KeyActionIndex++
                    return
                }
                
                ; Normal key processing
                direction := action[2]
                
                if (direction == "down") {
                    ActiveKey := key
                    Send "{" key " down}"
                    
                    ; Determine hold duration based on key type
                    if (key == "1" || key == "2") {
                        ; Weapon key - use shorter duration
                        KeyHoldDuration := Random(WeaponKeyHoldMin, WeaponKeyHoldMax)
                    } else {
                        ; Movement key - use longer duration
                        KeyHoldDuration := Random(MovementKeyHoldMin, MovementKeyHoldMax)
                    }
                    
                    KeyActionTime := A_TickCount + KeyHoldDuration
                    KeyActionState := 2 ; Move to waiting state
                } else {
                    ActiveKey := key
                    Send "{" key " up}"
                    ActiveKey := ""
                    
                    isLastInSequence := action.Length > 2 ? action[3] : false
                    if (isLastInSequence) {
                        ; Sequence complete
                        KeyActionState := 0
                        KeyActionIndex := 1
                        KeySequence := []
                    } else {
                        KeyActionTime := A_TickCount + KeyPauseDuration
                        KeyActionIndex++
                    }
                }
            } else {
                ; Sequence complete
                KeyActionState := 0
                KeyActionIndex := 1
                KeySequence := []
            }
            
        case 2: ; Key waiting (holding down)
            ; Time to release the key
            KeyActionState := 3
            
        case 3: ; Key up
            ; Get the current key from the sequence
            action := KeySequence[KeyActionIndex]
            key := action[1]
            isLastInSequence := action.Length > 2 ? action[3] : false
            
            ; Release the key
            Send "{" key " up}"
            ActiveKey := ""
            
            ; Move to the next key in sequence
            KeyActionIndex++
            KeyActionState := 1 ; Back to key down state for next key
            KeyActionTime := A_TickCount + KeyPauseDuration ; Configurable pause
    }
}

; Helper function to shuffle an array
ShuffleArray(arr) {
    Loop arr.Length {
        i := A_Index
        r := Random(i, arr.Length)
        tmp := arr[i]
        arr[i] := arr[r]
        arr[r] := tmp
    }
    return arr
}

; ────────────────────────────────────────────────────────────────
; HUD  (only shown when Roblox window is active)
; ────────────────────────────────────────────────────────────────
HUD() {
    global Debug, TargetWin, CurrentState, WaitTime
    global NextClick, NextMove, HudVisible, ActiveKey, KeyActionState
    global AvgClickInterval, TotalClicks
    
    if (!Debug || !WinActive(TargetWin)) {
        if (HudVisible) {
            ToolTip
            HudVisible := false
        }
        return
    }
    
    ; Determine state text
    stateText := "UNKNOWN"
    switch CurrentState {
        case STATE_DISABLED:
            stateText := "DISABLED"
        case STATE_ARMED:
            stateText := "ARMED"
        case STATE_RUNNING:
            stateText := "RUNNING"
    }
    
    ; Calculate values for display
    now := A_TickCount
    countdown := (CurrentState = STATE_ARMED) ? Round((WaitTime - A_TimeIdlePhysical)/1000, 1) : "-"
    tMove := (CurrentState = STATE_RUNNING) ? Round((NextMove - now)/1000, 1) : "-"
    
    ; Build HUD content conditionally based on state
    hudContent := "Anti‑AFK  [" stateText "]"
    
    ; Only show countdown when in ARMED state
    if (CurrentState = STATE_ARMED)
        hudContent .= "`nStart in: " countdown " s"
    
    ; Add click counter if greater than 0 (always visible regardless of state)
    if (TotalClicks > 0)
        hudContent .= "`nClicks: " TotalClicks
    
    ; Only show click info when in RUNNING state
    if (CurrentState = STATE_RUNNING) {
        clickAvg := AvgClickInterval ? AvgClickInterval : "-"
        hudContent .= "`nClick avg: " clickAvg " ms"
        clickStatus := ClicksEnabled ? "Enabled" : "Disabled"
        hudContent .= "`nClicks: " clickStatus
    }
    
    ; Only show next move when in RUNNING state
    if (CurrentState = STATE_RUNNING)
        hudContent .= "`nNext move: " tMove " s"
    
    ; Only show key info when in RUNNING state
    if (CurrentState = STATE_RUNNING) {
        keyInfo := ActiveKey ? "Key: " ActiveKey : "Key: none"
        hudContent .= "`n" keyInfo
    }
    
    hudContent .= "`nF9: Enable/Disable  |  F10: HUD"
    
    ; Display the HUD
    ToolTip hudContent, 10, 10
    HudVisible := true
}

; ────────────────────────────────────────────────────────────────
; HOTKEYS
; ────────────────────────────────────────────────────────────────
F9:: {
    global CurrentState, STATE_DISABLED, STATE_ARMED
    
    ; Toggle between DISABLED and ARMED states
    if (CurrentState = STATE_DISABLED)
        TransitionToState(STATE_ARMED)
    else
        TransitionToState(STATE_DISABLED)
}

F10:: {
    global Debug
    Debug := !Debug
    HUD()
}

; Pause key suspends the script
Pause::Suspend -1
