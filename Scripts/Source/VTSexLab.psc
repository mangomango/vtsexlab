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
GlobalVariable Property vtslFeedBlock Auto
dlc1vampireturnscript Property DLC1VampireTurn  Auto
Faction Property DLC1PotentialVampireFaction  Auto
Faction Property DLC1PlayerTurnedVampire  Auto
PlayerVampireQuestScript Property PlayerVampireQuest  Auto

event OnInit()
    RegisterForModEvent("OrgasmStart", "OnSexLabOrgasm")
    RegisterForModEvent("SexLabOrgasmSeparate", "OnSexLabOrgasmSeparate")
	RegisterForModEvent("HookAnimationStart", "OnAnimationStart")
	RegisterForModEvent("HookAnimationEnd", "OnAnimationEnd")
endEvent

Event OnAnimationStart(int threadID, bool HasPlayer)
{this handler and the one for animation end reset feeding block for multuple orgasms}
    if HasPlayer
        SexLab.Log("Animation starts, resetting feed blocks")
        vtslFeedBlock.Value = 0
    endif
EndEvent

Event OnAnimationEnd(int threadID, bool HasPlayer)
    if HasPlayer
        SexLab.Log("Animation ends, resetting feed blocks")
        vtslFeedBlock.Value = 0
    endif
EndEvent

event OnSexLabOrgasm(string hookName, string argString, float argNum, Form sender)
{Catch player orgasm events from SexLab}
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
            PlayerVampireQuest.VampireFeed(akAnother, button, 0, True)
        endif
    endIf
endEvent

event OnSexLabOrgasmSeparate(Form actorRef, int thread)
{Catch player orgasm events from SSO}
    SexLab.Log("SLSO orgasm event received")
    Actor akActor = ActorRef as Actor
    if akActor != PlayerRef
        SexLab.Log("SLSO - not a PC orgasm")
        return
    endif
    if vtslFeedBlock.GetValue() != 0
        SexLab.Log("SLSO - ignoring repeating orgasms")
        return
    endif
    String argString = thread as String
    Actor[] actorList = SexLab.HookActors(argString)
    Actor akAnother = none
    int i = 0
    while (i < actorList.Length)
        Actor ac = actorList[i]
        If ac != PlayerRef && (akAnother == none && (ac.HasSpell(SpFalmerAbilities) || ac.HasKeyword(KwActorTypeNPC)) && !ac.HasKeyword(KwActorTypeUndead) && !ac.HasKeyword(KwActorTypeDaedra) && !ac.HasKeyword(KwActorTypeDragon) && !ac.HasKeyword(KwActorTypeDwarven) && !ac.HasKeyword(KwActorTypeGhost) )
            ; found an actor suitable for feeding
            akAnother = ac
            SexLab.Log("Found a suitable NPC to feed on")
        endIf
        i += 1
    endWhile
    if akAnother != none
        SexLab.Log("Player orgasm, feeding")
        int button = FeedChoice.Show()
        If (button >= 0 && button <= 5)
            if akAnother.IsInFaction(DLC1PotentialVampireFaction) && akAnother.IsInFaction(DLC1PlayerTurnedVampire) == False
                DLC1VampireTurn.PlayerBitesMe(akAnother)
            endif
            PlayerVampireQuest.VampireFeed(akAnother, button, 0, True)
        endif
        ; if the player chooses to skip feeding - it's ignored for the rest of the session anyway
        vtslFeedBlock.Value = 1
    endIf
endEvent
