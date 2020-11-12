Scriptname VTSexLab Extends Quest Hidden

SexLabFramework Property SexLab Auto
Actor Property PlayerRef  Auto
Form Property SpFalmerAbilities Auto
Keyword Property KwActorTypeNPC Auto
Keyword Property KwActorTypeUndead Auto
Keyword Property KwActorTypeDaedra Auto
Keyword Property KwActorTypeDragon Auto
Keyword Property KwActorTypeDwarven Auto
Keyword Property KwActorTypeGhost Auto
Message Property FeedChoice  Auto 
mslVTMCMDebugSCR Property mslVTMCMQST  Auto
GlobalVariable  Property mslVTSetFeedMode  Auto
dlc1vampireturnscript Property DLC1VampireTurn  Auto
Faction Property DLC1PotentialVampireFaction  Auto
Faction Property DLC1PlayerTurnedVampire  Auto
PlayerVampireQuestScript Property PlayerVampireQuest  Auto

event OnInit()
    RegisterForModEvent("OrgasmStart", "OnSexLabOrgasm")
endEvent

event OnSexLabOrgasm(string hookName, string argString, float argNum, Form sender)
{Catch relevant orgasm events from SexLab}
    Actor[] actorList = SexLab.HookActors(argString)
    if actorList.Length < 2
        SexLab.Log("solo, no feeding")
        return
    endIf
    bool playerOrgasm = false
    Actor akAnother = none
    int i = 0
    while (i < actorList.Length)
        Actor ac = actorList[i]
        if (ac == PlayerRef)
            playerOrgasm = true
        ElseIf (akAnother == none && (ac.HasSpell(SpFalmerAbilities) || ac.HasKeyword(KwActorTypeNPC)) && !ac.HasKeyword(KwActorTypeUndead) && !ac.HasKeyword(KwActorTypeDaedra) && !ac.HasKeyword(KwActorTypeDragon) && !ac.HasKeyword(KwActorTypeDwarven) && !ac.HasKeyword(KwActorTypeGhost) )
            ; found an actor suitable for feeding
            akAnother = ac
        endIf
        i += 1
    endWhile
    if (playerOrgasm && akAnother != none)
        SexLab.Log("Player orgasm, feeding")
        int button = FeedChoice.Show()
        If (button >= 0 && button <= 5)
            if akAnother.IsInFaction(DLC1PotentialVampireFaction) && akAnother.IsInFaction(DLC1PlayerTurnedVampire) == False
                DLC1VampireTurn.PlayerBitesMe(akAnother)
            endif
            PlayerVampireQuest.VampireFeed(akAnother, button, 0)
        endif
    endIf
endEvent
