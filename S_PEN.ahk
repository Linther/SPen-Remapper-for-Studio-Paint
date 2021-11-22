SendMode Input
SetWorkingDir %A_ScriptDir%

global BUTTON_PRESSED := 8  ; button is pressed down
global BUTTON_RELEASED := 0 ; button is released 

global Logging := 0

WriteLog(text) {
    FileAppend, % A_NowUTC ": " text "`n", logfile.txt ; can provide a full path to write to another directory
}

#include AHKHID.ahk

WM_INPUT := 0xFF
USAGE_PAGE := 13
USAGE := 2

AHKHID_UseConstants()

AHKHID_AddRegister(1)
AHKHID_AddRegister(USAGE_PAGE, USAGE, A_ScriptHwnd, RIDEV_INPUTSINK)
AHKHID_Register()

OnMessage(WM_INPUT, "Work")

; This is where we remap the side button to the alt key.
PenCallback(input, lastInput) {
    WriteLog(input)
    if (input = BUTTON_PRESSED And lastInput = BUTTON_RELEASED) {
        Send {Alt Down}
        if (Logging = 1){
            WriteLog("Alt down")
        }
        
    }

    if (input = BUTTON_RELEASED And lastInput = BUTTON_PRESSED) {
        Send {Alt Up}
        if (Logging = 1){
            WriteLog("Alt Up")
        }
        
    }
}

Work(wParam, lParam) {

    Local type, inputInfo, inputData, raw, proc
    static lastInput := BUTTON_RELEASED

    Critical

    type := AHKHID_GetInputInfo(lParam, II_DEVTYPE)

    if (type = RIM_TYPEHID) {
        inputData := AHKHID_GetInputData(lParam, uData)
		raw := NumGet(uData, 0, "UInt")
			proc := (raw >> 8) & 0x1F
		if (proc <> lastInput) {

			PenCallback(proc, lastInput)
			
			lastInput := proc
		}
    }
}

