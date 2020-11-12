Scriptname VTSLHandler extends Quest Hidden

SexLabFramework Property SexLab Auto
Actor Property PlayerRef  Auto

Function StartFeedingSex(Actor akSpeaker)
    actor[] sexActors = new actor[2]
    sexActors[0] = PlayerRef
    sexActors[1] = akSpeaker
    sslBaseAnimation[] anims = SexLab.GetAnimationsByTags(2, "Vaginal,Anal,Oral", "", false)
    SexLab.StartSex(sexActors, anims)
EndFunction
