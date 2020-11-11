Scriptname VTSexLab Extends Quest Hidden

SexLabFramework Property SexLab Auto
Actor Property PlayerRef  Auto

event OnInit()
    RegisterForModEvent("OrgasmStart", "OnSexLabOrgasm")
endEvent

event OnSexLabOrgasm(string hookName, string argString, float argNum, Form sender)
{Catch relevant orgasm events from SexLab}
    Actor[] actorList = SexLab.HookActors(argString)
    bool playerOrgasm = false
    int i = 0
    while (i < actorList.Length)
        if (actorList[i] == PlayerRef)
            playerOrgasm = true
        endIf
        i += 1
    endWhile
    if playerOrgasm
        Debug.Notification("Orgasm!")
    endIf
endEvent
