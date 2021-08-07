Scriptname vtslHotkeys extends Quest  

GlobalVariable Property PlayerIsVampire Auto
Spell Property mslVTPwSubSenAVampiresSight Auto
GlobalVariable Property vtslKeyNightvision Auto

Event OnInit()
	RegisterHotkeys()
EndEvent

Function RegisterHotkeys()
	RegisterForKey(vtslKeyNightvision.GetValueInt())
EndFunction

Function UnRegisterHotkeys()
	UnRegisterForKey(vtslKeyNightvision.GetValueInt())
EndFunction

Event OnKeyDown(int keyCode)
	if Utility.IsInMenuMode() || PlayerIsVampire.GetValue() <= 0
		return
	endif
	If keyCode == vtslKeyNightvision.GetValueInt()
		mslVTPwSubSenAVampiresSight.Cast(Game.GetPlayer())
	Endif
EndEvent
