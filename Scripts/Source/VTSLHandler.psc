Scriptname VTSLHandler extends Quest Hidden

SexLabFramework Property SexLab Auto
Actor Property PlayerRef  Auto

Function StartFeedingSex(Actor akSpeaker)
    actor[] sexActors = new actor[2]
    sexActors[0] = PlayerRef
    sexActors[1] = akSpeaker
    sslBaseAnimation[] anims = SexLab.GetAnimationsByTags(2, "Vampire")
    if (anims.Length == 0)
        ; fallback to default sex animations if no vampire anims. found
        anims = SexLab.GetAnimationsByTags(2, "Vaginal,Anal,Oral", "", false)
    endif
    SexLab.StartSex(sexActors, anims)
EndFunction
