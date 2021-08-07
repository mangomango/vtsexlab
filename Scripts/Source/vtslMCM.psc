Scriptname vtslMCM extends SKI_ConfigBase  

vtslHotkeys Property vtslHotkeyMgr auto
GlobalVariable Property vtslKeyNightvision Auto
GlobalVariable Property vtslAgeHungerRateDecrease Auto
GlobalVariable Property vtslFeedArousal Auto
GlobalVariable Property vtslFeedingOrgasm Auto

int _oid_keyVampireSight
int _oid_feedOnOrgasm
int _oid_AgeHungerRateDecrease
string[] _val_feedOnOrgasmLabels

int function GetVersion()
	return 2
endFunction

event OnConfigInit()
	Pages = new string[1]
	Pages[0] = "Main"
    _val_feedOnOrgasmLabels = new string[2]
    _val_feedOnOrgasmLabels[0] = "PC orgasm"
    _val_feedOnOrgasmLabels[1] = "Partner orgasm"
endEvent

event OnPageReset(string page)
    if (page == "Main")
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)
        AddHeaderOption("Game settings")
        _oid_AgeHungerRateDecrease = AddSliderOption("Decrease of the hunger rate with age", vtslAgeHungerRateDecrease.Value as float, "{1}x")
        AddHeaderOption("SexLab - Separate Orgasms")
        _oid_feedOnOrgasm = AddMenuOption("Feed on orgasm...", _val_feedOnOrgasmLabels[vtslFeedingOrgasm.Value as int])
		SetCursorPosition(1)
        AddHeaderOption("Hotkeys")
        _oid_keyVampireSight = AddKeyMapOption("Vampire Sight", vtslKeyNightvision.Value as Int)
    endif
endEvent

event OnOptionMenuOpen(int option)
	if (option == _oid_feedOnOrgasm)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_val_feedOnOrgasmLabels)
		SetMenuDialogStartIndex(vtslFeedingOrgasm.Value as int)
	endIf
endEvent

event OnOptionMenuAccept(int option, int index)
	if (option == _oid_feedOnOrgasm)
        if index >= 0 && index < _val_feedOnOrgasmLabels.length
            SetMenuOptionValue(option, _val_feedOnOrgasmLabels[index])
            vtslFeedingOrgasm.Value = index
        endif
	endIf
endEvent

event OnOptionSliderOpen(int option)
	if (option == _oid_AgeHungerRateDecrease)
		SetSliderDialogStartValue(vtslAgeHungerRateDecrease.Value as float)
		SetSliderDialogDefaultValue(2.0)
		SetSliderDialogRange(1.0, 5.0)
		SetSliderDialogInterval(0.1)
	endIf
endEvent

event OnOptionSliderAccept(int option, float value)
	if (option == _oid_AgeHungerRateDecrease)
		vtslAgeHungerRateDecrease.Value = value
		SetSliderOptionValue(option, value, "{1}x")
	endIf
endEvent

Function AssignKey(globalvariable hotKey, int option, int keyCode, string conflictControl, string conflictName)
    bool continue = true
    if (conflictControl != "")
        string msg
        if (conflictName != "")
            msg = "This key is already mapped to:\n" + conflictControl + "\n(" + conflictName + ")\n\nAre you sure you want to continue?"
        else
            msg = "This key is already mapped to:\n" + conflictControl + "\n\nAre you sure you want to continue?"
        endIf

        continue = ShowMessage(msg, true, "Yes", "No")
    endIf
    if (continue)
        hotKey.Value = keyCode
        SetKeymapOptionValue(option, keyCode)
        vtslHotkeyMgr.RegisterHotkeys()
    endIf
EndFunction


string Function GetCustomControl(int keyCode)
	if (keyCode == vtslKeyNightvision.Value)
		return "Vampire Sight"
	else
		return ""
	endIf
endFunction

event OnOptionKeyMapChange(int option, int keyCode, string conflictControl, string conflictName)
	if (option == _oid_keyVampireSight)
			AssignKey(vtslKeyNightvision, option, keyCode, conflictControl, conflictName)
	endIf
endEvent
