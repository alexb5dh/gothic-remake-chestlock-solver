#Requires AutoHotkey v2.0
#SingleInstance Force

DELAY := 200

SetTimer(WatchFile, 1000)
WatchFile() {
    static lastMod := FileGetTime(A_ScriptFullPath, "M")
    current := FileGetTime(A_ScriptFullPath, "M")
    if (current != lastMod) {
        lastMod := current
        Run('"' A_AhkPath '" "' A_ScriptFullPath '" /reloaded')
        ExitApp
    }
}

if (A_Args.Length > 0 && A_Args[1] = "/reloaded") {
    ToolTip("Reloaded")
    SetTimer(() => ToolTip(), -1500)
}

parts := []
idx := 0
sending := false

SendNext() {
    global parts, idx, sending
    idx++
    if (idx > parts.Length) {
        SetTimer(SendNext, 0)
        ToolTip("Done (" parts.Length " keys)")
        SetTimer(() => ToolTip(), -2000)
        sending := false
        return
    }
    ToolTip("Sending " idx "/" parts.Length)
    SendEvent("{" parts[idx] " down}")
    Sleep(50)
    SendEvent("{" parts[idx] " up}")
}

#HotIf WinActive("ahk_exe G1R-Win64-Shipping.exe")
l:: {
    global parts, idx, sending
    if (sending) {
        SetTimer(SendNext, 0)
        ToolTip("Cancelled at " idx "/" parts.Length)
        SetTimer(() => ToolTip(), -2000)
        sending := false
        return
    }
    seq := A_Clipboard
    if (seq = "") {
        ToolTip("Clipboard empty")
        SetTimer(() => ToolTip(), -1500)
        return
    }
    parts := StrSplit(seq, ",", " ")
    idx := 0
    sending := true
    ToolTip("Sending " parts.Length " keys...")
    SetTimer(SendNext, DELAY)
}
#HotIf
