Scriptname VTSLHandler extends Quest Hidden

SexLabFramework Property SexLab Auto
Actor Property PlayerRef  Auto

Function StartFeedingSex(Actor akSpeaker)
    actor[] sexActors = new actor[2]
    sexActors[0] = PlayerRef
    sexActors[1] = akSpeaker
    sslBaseAnimation[] anims
    int sexPlayer = PlayerRef.GetActorBase().GetSex()
    int sexSpeaker = akSpeaker.GetLeveledActorBase().GetSex()
    if sexPlayer == 0 ; male vampire
        anims = SexLab.GetAnimationsByTags(2, "Vapire,FM")
    Else ; female vampire
        if sexSpeaker == 0 ; female vampire on male victims
            anims = SexLab.GetAnimationsByTags(2, "Cowgirl")
        else ; female vampire FF
            anims = SexLab.GetAnimationsByTags(2, "Vaginal,Facing,Loving", "Furniture,Aggressive,Anal")
        endif
    endif
    If Game.GetModByName("SexLab Eager NPCs.esp") != 255
        SexLab.Log("attempting to increase SLEN relationship status")
        SLENMainController slenc = Game.GetFormFromFile(0x0D62,"SexLab Eager NPCs.esp") AS SLENMainController
        slenc.QueueModPlayerLove(akSpeaker, 33)
    endif
    SexLab.StartSex(sexActors, anims)
EndFunction
