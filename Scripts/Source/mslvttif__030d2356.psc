;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname mslVTTIF__030D2356 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
    Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
;Debug.MessageBox("AND THIS THING MAKES SHOES FOR ORPHANS")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
    Actor akSpeaker = akSpeakerRef as Actor
    ;BEGIN CODE
    ;Debug.MessageBox("I AM THE VANGUARD OF YOUR DISTRACTION")
    akSpeaker.AddToFaction(mslVTFeedDialogueLastingSedFAC)

    If mslVTMCMQST.CheckNoBite(Game.GetPlayer())
    ;do nothing
    Else
        If mslVTSetFeedMode.Value == 0
            Handler.StartFeedingSex(akSpeaker)
        Else
            if akSpeaker.IsInFaction(DLC1PotentialVampireFaction) && akSpeaker.IsInFaction(DLC1PlayerTurnedVampire) == False
                DLC1VampireTurn.PlayerBitesMe(akSpeaker)
            endif
            PlayerVampireQuest.VampireFeedSus(akSpeaker, 1, 0)
        Endif
    Endif
    if mslVTSetDialSpeech.Value == 1
        DialogueFavorGeneric.Persuade(akSpeaker)
    endif
    akSpeaker.RemoveFromFaction(mslVTFeedDialogueFailFAC)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

PlayerVampireQuestScript Property PlayerVampireQuest  Auto  

Message Property FeedChoice  Auto  

dlc1vampireturnscript Property DLC1VampireTurn  Auto  

Faction Property DLC1PotentialVampireFaction  Auto  

Faction Property DLC1PlayerTurnedVampire  Auto  

Idle Property FeedDialogueIdle  Auto  

GlobalVariable  Property mslVTSetFeedMode  Auto  

FavorDialogueScript Property DialogueFavorGeneric  Auto  

Faction Property mslVTFeedDialogueFailFAC  Auto  

Faction Property mslVTFeedDialogueLastingSedFAC  Auto  

GlobalVariable Property mslVTSetDialSpeech  Auto  

mslVTMCMDebugSCR Property mslVTMCMQST  Auto  

VTSLHandler Property Handler Auto
