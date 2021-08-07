ScriptName PlayerVampireQuestScript extends Quest Conditional

;Importing functions from other scripts
Import Game
Import Debug
Import Utility

;Variable to track if the player is a vampire
;0 = Not a Vampire
;1 = Vampire
;2 = Vampire Stage 2
;3 = Vampire Stage 3
;4 = Vampire Stage 4
Int Property VampireStatus Auto Conditional

Message Property VampireFeedMessage Auto
Message Property VampireStageProgressionMessage Auto

Race Property CureRace Auto
Static Property XMarker Auto

Faction Property VampirePCFaction  Auto  

Float Property LastFeedTime Auto
Float Property FeedTimer Auto
GlobalVariable Property GameDaysPassed Auto
GlobalVariable Property GameHour  Auto
GlobalVariable Property vtslAgeHungerRateDecrease Auto

Idle Property VampireFeedingBedRight Auto
Idle Property VampireFeedingBedrollRight Auto
GlobalVariable Property VampireFeedReady Auto
imageSpaceModifier Property VampireTransformIncreaseISMD  Auto
imageSpaceModifier Property VampireTransformDecreaseISMD  Auto 
effectShader property VampireChangeFX auto
slaFrameworkScr property SLAFramework auto
GlobalVariable Property vtslFeedArousal Auto

float Property TimeOld Auto
float Property TimeNew Auto
float Property TimePassed Auto

float Function RealTimeSecondsToGameTimeDays(float realtime)
	float scaledSeconds = realtime * TimeScale.Value
	return scaledSeconds / (60 * 60 * 24)
EndFunction

float Function GameTimeDaysToRealTimeSeconds(float gametime)
	float gameSeconds = gametime * (60 * 60 * 24)
	return (gameSeconds / TimeScale.Value)
EndFunction

Event OnUpdate()

;Checking if player is a vampire

	If PlayerIsVampire.Value > 0

;Timescale adjuster so that the math is right no matter what scale player has set

	float TSAdjust = TimeScale.GetValue()/60

;Active and Natural detorioration levels (I don't care how it's spelled!)
;Natural detorioration is equal to 1 blood point every game time minute (default)
;Active detorioration is modified by toggleable powers and equals 0 if none are active

	float DetActVar = (DetAct.GetValue()*TSAdjust)*DetActMult.GetValue()
	float DetNatVar = (DetNat.GetValue()*TSAdjust)*DetNatMult.GetValue()

;Maximum and Current blood levels

	float BloodCurVar = BloodCur.GetValue()
	float BloodMaxVar = BloodMax.GetValue() + BloodMaxMod.GetValue()

;Informng player if the blood pool is full

	if BloodCurVar >= BloodMaxVar
		;Notification("I feel full, my hunger is quiet.")
		mslVTHunFullMSG.Show()
	endif

;Checking for passage of time (including large time jumps like sleep, fast travel and so on)

	TimeNew = GameDaysPassed.GetValue()
	TimePassed = TimeNew - TimeOld
	float DetMult = GameTimeDaysToRealTimeSeconds(TimePassed)
	float age = mslVTAge.GetValue()
	If age < 1
		age = 1
	EndIf
	If TimeOld != 0
		BloodCurVar = BloodCur.GetValue() - (DetActVar + DetNatVar)*DetMult / age
		mslVTExp.Mod(((DetAct.GetValue()*TSAdjust)*DetMult/vtslAgeHungerRateDecrease.GetValue()*mslVTExpMult.GetValue()))
	Endif

;	MessageBox("This much game time has passed: " + TimePassed + " Old: " + TimeOld + " New: " + TimeNew)
;	MessageBox("This much real time has passed: " + DetMult + " seconds")

	TimeOld = GameDaysPassed.GetValue()

;Updating globals

	BloodCur.SetValue(BloodCurVar)

;Imposing bottom and top limits

	If (BloodCurVar > BloodMaxVar)
		BloodCur.SetValue(BloodMaxVar)
	Elseif (BloodCurVar < 0)
		BloodCur.SetValue(0)
	Endif

;Manage hunger state abilities

	If (BloodCurVar <= 0 && akPlayer.HasSpell(HungerState5) == 0)
		akPlayer.RemoveSpell(HungerState1)
		akPlayer.RemoveSpell(HungerState2)
		akPlayer.RemoveSpell(HungerState3)
		akPlayer.RemoveSpell(HungerState4)
		akPlayer.AddSpell(HungerState5, false)
		VampireStatus = 4
		VampireProgression(akPlayer, 4)
		;Notification("")
	Elseif (BloodCurVar <= 15*BloodMaxVar/100 && BloodCurVar > 0*BloodMaxVar/100 && akPlayer.HasSpell(HungerState4) == 0)
		akPlayer.RemoveSpell(HungerState1)
		akPlayer.RemoveSpell(HungerState2)
		akPlayer.RemoveSpell(HungerState3)
		akPlayer.AddSpell(HungerState4, false)
		akPlayer.RemoveSpell(HungerState5)
		VampireStatus = 3
		VampireProgression(akPlayer, 3)
		;Notification("")
	Elseif (BloodCurVar <= 30*BloodMaxVar/100 && BloodCurVar > 15*BloodMaxVar/100 && akPlayer.HasSpell(HungerState3) == 0)
		akPlayer.RemoveSpell(HungerState1)
		akPlayer.RemoveSpell(HungerState2)
		akPlayer.AddSpell(HungerState3, false)
		akPlayer.RemoveSpell(HungerState4)
		akPlayer.RemoveSpell(HungerState5)
		VampireStatus = 3
		VampireProgression(akPlayer, 3)
		;Notification("")
	Elseif (BloodCurVar <= 50*BloodMaxVar/100 && BloodCurVar > 30*BloodMaxVar/100 && akPlayer.HasSpell(HungerState2) == 0)
		akPlayer.RemoveSpell(HungerState1)
		akPlayer.AddSpell(HungerState2, false)
		akPlayer.RemoveSpell(HungerState3)
		akPlayer.RemoveSpell(HungerState4)
		akPlayer.RemoveSpell(HungerState5)
		VampireStatus = 2
		VampireProgression(akPlayer, 2)
		;Notification("")
	Elseif (BloodCurVar < 90*BloodMaxVar/100 && BloodCurVar > 50*BloodMaxVar/100 && (akPlayer.HasSpell(HungerState1) || akPlayer.HasSpell(HungerState2) || akPlayer.HasSpell(HungerState3) || akPlayer.HasSpell(HungerState4) || akPlayer.HasSpell(HungerState5)))
		akPlayer.RemoveSpell(HungerState1)
		akPlayer.RemoveSpell(HungerState2)
		akPlayer.RemoveSpell(HungerState3)
		akPlayer.RemoveSpell(HungerState4)
		akPlayer.RemoveSpell(HungerState5)
		VampireStatus = 2
		VampireProgression(akPlayer, 2)
		;Notification("")
	Elseif (BloodCurVar >= 90*BloodMaxVar/100 && akPlayer.HasSpell(HungerState1) == 0)
		akPlayer.AddSpell(HungerState1, false)
		akPlayer.RemoveSpell(HungerState2)
		akPlayer.RemoveSpell(HungerState3)
		akPlayer.RemoveSpell(HungerState4)
		akPlayer.RemoveSpell(HungerState5)
		VampireStatus = 1
		VampireProgression(akPlayer, 1)
		;Notification("")
	Endif

;Manage ageing and experience

	;If akPlayer.IsInCombat() == 0
		If mslVTAge.GetValue() < 1 && (QueryStat("Days as a Vampire") +  mslVTAgeDiablerieMod.GetValue())*mslVTSetAgeingMult.GetValue() <= (AgeReq.GetAt(1) as GlobalVariable).GetValue()
			int Index = 0
			while (Index < AgeStages.GetSize())
				akPlayer.RemoveSpell(AgeStages.GetAt(Index) as Spell)
				Index += 1
			endwhile
			akPlayer.AddSpell(AgeStages.GetAt(0) as Spell, false)
			BloodMax.SetValue(1000)
			DetNat.SetValue(1.0)
			mslVTAge.SetValue(1)
		Elseif mslVTAge.GetValue() < 2 && (QueryStat("Days as a Vampire") +  mslVTAgeDiablerieMod.GetValue())*mslVTSetAgeingMult.GetValue() > (AgeReq.GetAt(1) as GlobalVariable).GetValue()
			int Index = 0
			while (Index < AgeStages.GetSize())
				akPlayer.RemoveSpell(AgeStages.GetAt(Index) as Spell)
				Index += 1
			endwhile
			akPlayer.AddSpell(AgeStages.GetAt(1) as Spell, false)
			BloodMax.SetValue(1300)
			DetNat.SetValue(0.9)
			mslVTAge.SetValue(2)
		Elseif mslVTAge.GetValue() < 3 && (QueryStat("Days as a Vampire") +  mslVTAgeDiablerieMod.GetValue())*mslVTSetAgeingMult.GetValue() > (AgeReq.GetAt(2) as GlobalVariable).GetValue()
			int Index = 0
			while (Index < AgeStages.GetSize())
				akPlayer.RemoveSpell(AgeStages.GetAt(Index) as Spell)
				Index += 1
			endwhile
			akPlayer.AddSpell(AgeStages.GetAt(2) as Spell, false)
			BloodMax.SetValue(1700)
			DetNat.SetValue(0.8)
			mslVTAge.SetValue(3)
		Elseif mslVTAge.GetValue() < 4 && (QueryStat("Days as a Vampire") +  mslVTAgeDiablerieMod.GetValue())*mslVTSetAgeingMult.GetValue() > (AgeReq.GetAt(3) as GlobalVariable).GetValue()
			int Index = 0
			while (Index < AgeStages.GetSize())
				akPlayer.RemoveSpell(AgeStages.GetAt(Index) as Spell)
				Index += 1
			endwhile
			akPlayer.AddSpell(AgeStages.GetAt(3) as Spell, false)
			BloodMax.SetValue(2200)
			DetNat.SetValue(0.7)
			mslVTAge.SetValue(4)
		Elseif mslVTAge.GetValue() < 5 && (QueryStat("Days as a Vampire") +  mslVTAgeDiablerieMod.GetValue())*mslVTSetAgeingMult.GetValue() > (AgeReq.GetAt(4) as GlobalVariable).GetValue()
			int Index = 0
			while (Index < AgeStages.GetSize())
				akPlayer.RemoveSpell(AgeStages.GetAt(Index) as Spell)
				Index += 1
			endwhile
			akPlayer.AddSpell(AgeStages.GetAt(4) as Spell, false)
			BloodMax.SetValue(2800)
			DetNat.SetValue(0.6)
			mslVTAge.SetValue(5)
		Endif
	;Endif

	float ExpCurrent = mslVTExp.GetValue()
	float ExpNext = 500*mslVTExpLevel.GetValue()+250*mslVTExpLevel.GetValue()*mslVTExpLevel.GetValue()/2

	If ExpNext <= ExpCurrent
		mslVTExpLevel.Mod(1)
		mslVTExpPoints.Mod(1)
		;Notification("I can feel the power of my blood growing!")
		mslVTAdvanceMSG.Show()
		mslVTAdvanceSM.Play(akPlayer)
	Endif

	;Notification("Current experience: " + ExpCurrent + ", next level: " + ExpNext + ", level: " + mslVTExpLevel.GetValue())

	mslVTFeedDialogueSpeech.SetValue(akPlayer.GetBaseActorValue("Speechcraft"))

	Endif

		RegisterForSingleUpdate(1)
	
EndEvent

;Alias control

Function SetPlayerAlias(bool Fill)
	If Fill == TRUE
		PlayerVampireAlias.ForceRefTo(akPlayer)
		SendModEvent("VTAliasFilled")
;		MessageBox("Filled!")
	Else
		PlayerVampireAlias.Clear()
		SendModEvent("VTAliasCleared")
;		MessageBox("Cleared!")
	Endif
Endfunction

;Update procedure

Function StartVTUpdate()
	If PlayerIsVampire.Value > 0

		SetPlayerAlias(FALSE)
		akPlayer.RemoveSpell(VampireVampirism)
		akPlayer.RemoveSpell(VampirePoisonResist)
		akPlayer.RemoveSpell(VampireHuntersSight)
		akPlayer.RemoveSpell(mslVTHotkeyControl)
		akPlayer.RemoveSpell(mslVTPSMenu)
		akPlayer.RemoveSpell(mslVTFeedAction)
		akPlayer.RemoveSpell(mslVTFeedTokenControlCloak)
		SetPlayerAlias(TRUE)

		akPlayer.RemoveFromFaction(VampirePCFaction)
		akPlayer.SetAttackActorOnSight(False)

		int cfIndex = 0
		while (cfIndex < CrimeFactions.GetSize())
			(CrimeFactions.GetAt(cfIndex) as Faction).SetPlayerEnemy(false)
			cfIndex += 1
		endwhile

		mslVTAge.Value = 0

		mslVTSetNPCPowers.Value = 0
		mslVTSetNPCPowers.Value = 1

		RegisterForSingleUpdate(1)

	Endif

;	Notification("Vampiric Thirst has finished updating!")

EndFunction

;Authentication check

bool Function AuthenticateScript()
	return True
EndFunction

;Toggle appearance function

Function ToggleAppearance(int Mode, actor Target)
	If PlayerIsVampire.Value != 0
		SetPlayerAlias(FALSE)
		if Mode == 0	;vamp me up!
			if Races.HasForm(Target.GetActorBase().GetRace())
				int Index = 0
				bool RaceChanged = FALSE
				while (RaceChanged == FALSE)
					if (Target.GetActorBase().GetRace() == (Races.GetAt(Index) as Race))
;						MessageBox("Player's mortal race is " + (Races.GetAt(Index) as Race))
						Target.SetRace(RacesVampires.GetAt(Index) as Race)
;						wait(2.0)
;						MessageBox("Player's vampire race is " + (RacesVampires.GetAt(Index) as Race))
						RaceChanged = TRUE
					else
						Index += 1
					endif
				endwhile
			endif
		else				;normal me up!
			if RacesVampires.HasForm(Target.GetActorBase().GetRace())
				int Index = 0
				bool RaceChanged = FALSE
				while (RaceChanged == FALSE)
					if (Target.GetActorBase().GetRace() == (RacesVampires.GetAt(Index) as Race))
;						MessageBox("Player's vampire race is " + (RacesVampires.GetAt(Index) as Race))
						Target.SetRace(Races.GetAt(Index) as Race)
;						wait(2.0)
;						MessageBox("Player's mortal race is " + (Races.GetAt(Index) as Race))
						RaceChanged = TRUE
					else
						Index += 1
					endif
				endwhile
			endif
		endif
	akPlayer.RemoveSpell(VampireVampirism)
	akPlayer.RemoveSpell(VampirePoisonResist)
	akPlayer.RemoveSpell(VampireHuntersSight)
	SetPlayerAlias(TRUE)
	Endif
EndFunction

;Modified VampireProgression function

Function VampireProgression(Actor Player, int VampireStage)

	If VampireStage == 1 || VampireStage == 2 || VampireStage == 3
		VampireTransformIncreaseISMD.applyCrossFade(2.0)
		wait(2.0)
		imageSpaceModifier.removeCrossFade()
		RedVisionImod.Remove()

	ElseIf VampireStage == 4
		VampireTransformIncreaseISMD.applyCrossFade(2.0)
		wait(2.0)
		imageSpaceModifier.removeCrossFade()
		RedVisionImod.Remove()
		RedVisionImod.Apply(1.0)

	EndIf

EndFunction

Function VampireFeedBed()

	akPlayer.PlayIdle(VampireFeedingBedRight)

EndFunction

Function VampireFeedBedRoll()

	akPlayer.PlayIdle(VampireFeedingBedrollRight)

EndFunction

Function VampireChange(Actor Target)

	;Start dramatic scene of death, prepare some tissues
	;Notification("Something is wrong... I feel strange...")
	mslVTChangeMSG.Show()
	
	DeathCloseSound.Play(Target)
	wait(1.0)
	
	FadeToBlackISMD.apply()
	wait(1.0)
	DisablePlayerControls()
		If (mslVTSetDeathSceneAnim.Value == 1) && !Target.IsInLocation(CastleVolkiharLoc)
	Target.PlayIdle(Faint)
		Endif
	DeathSoundToMute.Mute()
	wait(0.5)
		If (mslVTSetDeathSceneAnim.Value == 1) && !Target.IsInLocation(CastleVolkiharLoc)
	Target.PushActorAway(Target, 1)
		Endif
	wait(2.0)
	ObjectReference myXmarker = Target.PlaceAtMe(Xmarker)
	DeathSoundTransform.Play(myXmarker)
	myXmarker.Disable()

	;Check if it's our first time, needed for a quest I'm planning
	If mslVTStoryline.GetValue() == 0
		mslVTStoryline.SetValue(1)
	Endif

	;Stay dead for some time and make sure it's night when player wakes up
	;Play japanese commercial during blackout to distract player from noticing our cheap tricks

	If (GameHour.GetValue() < 20) && (GameHour.GetValue() > 4)
		GameHour.SetValue(20)
	Endif

	wait(3.0)

	;Change player's race, check FormList "mslVTRacesFL" for viable races, vampire race MUST have the same index as its mortal version on the "mslVTRacesVampiresFL" list!

	SetPlayerAlias(FALSE)

	if Races.HasForm(Target.GetActorBase().GetRace()) && mslVTSetAppearance.GetValue() == 0
		int Index = 0
		bool RaceChanged = FALSE
		while (RaceChanged == FALSE)
			if (Target.GetActorBase().GetRace() == (Races.GetAt(Index) as Race))
;				MessageBox("Player's mortal race is " + (Races.GetAt(Index) as Race))
				Target.SetRace(RacesVampires.GetAt(Index) as Race)
;				wait(2.0)
;				MessageBox("Player's vampire race is " + (RacesVampires.GetAt(Index) as Race))
				RaceChanged = TRUE
			else
				Index += 1
			endif
		endwhile
	endif

	SetPlayerAlias(TRUE)

	;Clear player's diseases
	Target.AddSpell(VampireCureDisease, false)
	VampireCureDisease.Cast(Target)
	Target.RemoveSpell(VampireCureDisease)

	PlayerIsVampire.SetValue(1)
	
	wait(1.0)
	If (mslVTSetDeathSceneAnim.Value == 1) && !Target.IsInLocation(CastleVolkiharLoc)
		Target.PushActorAway(Target, 1)
	Endif
	wait(1.0)
	EnablePlayerControls()
	FadeToBlackISMD.popto(FadeFromBlackISMD)

	If BloodMax.GetValue() <= 0
		BloodMax.SetValue(1000)
	Endif

	;Give player some starting blood (converted from health)
	BloodCur.SetValue(akPlayer.GetActorValue("health"))

	wait(10.0)
	DeathSoundToMute.UnMute()
	wait(5.0)

	DateOfChange.SetValue(GameDaysPassed.GetValue())

	UnRegisterForUpdate()
	RegisterForSingleUpdate(1)

	;If the player has been cured before, restart the cure quest
	If VC01.GetStageDone(200) == 1
		VC01.SetStage(25)
	EndIf

	Target.AddSpell(VampiresSightSP, false)

	SendModEvent("VTVampireChange")

	Target.SendVampirismStateChanged(true)
	
EndFunction

Function VampireFeed(Actor akTarget, Int FeedType = 0, Int PassOut = 0)
{{ passOut: 0 - no passout 1 - normal passout 2 - feeding during sex }
	FeedISMD.apply()

	int MaxHealth = (akTarget.GetAV("Health") as int)
	bool QLT = FALSE

	If akTarget.GetAV("Variable08") <= 0
		Game.IncrementStat( "Necks Bitten" )
	Endif

	QualityMult = 1
	If mslVTSetBloodQuality.GetValue() >= 1
		;CheckBloodQuality(akTarget, 1)
		QualityMult = QualityMult + akTarget.GetAV("Infamy")*0.01
		If akPlayer.HasMagicEffect(mslVTBloodAddictionME) && akTarget.GetAV("Infamy") < AddictionBar.Value
			QualityMult = QualityMult/2
		Endif
		;MessageBox("Quality equals:" + QualityMult)
	Endif

	(FeedGlobal.GetAt(0) as GlobalVariable).SetValue(akTarget.GetBaseAV("Health")*0.10)
	(FeedGlobal.GetAt(1) as GlobalVariable).SetValue(akTarget.GetBaseAV("Health")*0.25)
	(FeedGlobal.GetAt(2) as GlobalVariable).SetValue(akTarget.GetBaseAV("Health")*0.50)
	(FeedGlobal.GetAt(3) as GlobalVariable).SetValue((BloodMax.GetValue() + BloodMaxMod.GetValue() - BloodCur.GetValue())/(BloodRatio.GetValue()*QualityMult))
	(FeedGlobal.GetAt(4) as GlobalVariable).SetValue(akTarget.GetAV("Health"))

	if akPlayer.GetRace() != DLC1VampireBeastRace
		akPlayer.SetRestrained(true)
	endif
	if !akTarget.IsDead()
		akTarget.SetRestrained(true)
	endif

	;Feed on corpse
	If FeedType < 0
		BloodCur.Mod((akTarget.GetBaseAV("Health")*0.5)*QualityMult)
		Qlt = TRUE
		mslVTExp.Mod(((akTarget.GetBaseAV("Health")*0.5)*QualityMult)/5*mslVTExpMult.GetValue())
		akTarget.ModAV("Variable08", 1)
	;Normal options
	Elseif FeedType == 0 || FeedType == 1 || FeedType == 2 || FeedType == 3 || FeedType == 4
		If (Feedtype != 4) && (akTarget.GetAV("Health") > (FeedGlobal.GetAt(FeedType) as GlobalVariable).GetValue())
			BloodCur.Mod((FeedGlobal.GetAt(FeedType) as GlobalVariable).GetValue()*BloodRatio.GetValue()*QualityMult)
			akTarget.DamageAV("Health", (FeedGlobal.GetAt(FeedType) as GlobalVariable).GetValue())
			akPlayer.RestoreAV("Health", (FeedGlobal.GetAt(FeedType) as GlobalVariable).GetValue())
			akTarget.ModAV("Variable08", ((FeedGlobal.GetAt(FeedType) as GlobalVariable).GetValue())/(akTarget.GetBaseAV("Health")))
			mslVTExp.Mod(((FeedGlobal.GetAt(FeedType) as GlobalVariable).GetValue()*BloodRatio.GetValue()*QualityMult)/5*mslVTExpMult.GetValue())
			akTarget.ModAV("Infamy", ((FeedGlobal.GetAt(FeedType) as GlobalVariable).GetValue())/(akTarget.GetBaseAV("Health"))*PercentMult.Value)
			akTarget.AddToFaction(mslVTFeedRecoveryFAC)
			Qlt = TRUE
			if mslVTFeedDelay.value > 0
				wait(mslVTFeedDelay.value)
			endif
		Else
			If mslVTSetKillEssential.GetValue() == 0 && akTarget.IsEssential()
				;Notification("This one cannot be drained dry.")
				mslVTFeedEssentialFailMSG.Show()
			Else	
				BloodCur.Mod(akTarget.GetAV("Health")*BloodRatio.GetValue()*QualityMult)
				akPlayer.RestoreAV("Health", akTarget.GetAV("Health"))
				mslVTExp.Mod((akTarget.GetAV("Health")*BloodRatio.GetValue()*QualityMult)/5*mslVTExpMult.GetValue())
				akTarget.ModAV("Variable08", 1)
				akTarget.ModAV("Infamy", ((FeedGlobal.GetAt(FeedType) as GlobalVariable).GetValue())/(akTarget.GetBaseAV("Health"))*PercentMult.Value)
				Qlt = TRUE
				if mslVTFeedDelay.value > 0
					wait(mslVTFeedDelay.value)
				endif
				if akTarget.HasKeyword(Vampire) || NPCVampireBosses.HasForm(akTarget.GetActorBase())
					if NPCVampireBosses.HasForm(akTarget.GetActorBase())
						mslVTAgeDiablerieMod.Mod(akTarget.GetLevel()*0.2)
					else
						mslVTAgeDiablerieMod.Mod(akTarget.GetLevel()*0.1)
					endif
						;Debug.Notification("This vampire's blood feels powerful and as the last drop of it trickles down my throat... so do I!")
						mslVTFeedDiablerieMSG.Show()
				endif
				akTarget.DamageAV("Health", akTarget.GetAV("Health"))
				akTarget.KillEssential(akPlayer)
			Endif
		Endif
	;Bottle blood
	Elseif FeedType == 5
		If akTarget.GetAV("Health") > (FeedGlobal.GetAt(0) as GlobalVariable).GetValue()
			akTarget.ModAV("Variable08", ((FeedGlobal.GetAt(0) as GlobalVariable).GetValue())/(akTarget.GetBaseAV("Health")))
			akTarget.ModAV("Infamy", ((FeedGlobal.GetAt(0) as GlobalVariable).GetValue())/(akTarget.GetBaseAV("Health"))*PercentMult.Value)
			akTarget.AddToFaction(mslVTFeedRecoveryFAC)
			int Index = 0
			bool EmptyRemoved = FALSE
			while (EmptyRemoved == FALSE)
				if Index > 10
					EmptyRemoved = TRUE
				else
					if akPlayer.GetItemCount(EmptyBottles.GetAt(Index) as Form)
						akPlayer.RemoveItem(EmptyBottles.GetAt(Index) as Form, 1)
						akPlayer.AddItem(BottledBloodPOT)
						EmptyRemoved = TRUE
						Index += 1
					else
						Index += 1
					endif
				endif
			endwhile
		Else
			;Notification("There is hardly enough blood left to fill a spoon let alone a bottle!")
			mslVTFeedBottleFailMSG.Show()
		Endif
	Endif

	LastFeedTime =  GameDaysPassed.Value

	akPlayer.SetRestrained(false)
	if !akTarget.IsDead()
		akTarget.SetRestrained(false)
	endif

	If PassOut == 1
		mslVTFeedFaint.Cast(akPlayer, akTarget)
	Endif

	int feedArousal = vtslFeedArousal.GetValue() as int
	if passOut != 2 && feedArousal > 0 
		SLAFramework.UpdateActorExposure(akPlayer, feedArousal, "feeding")
	Endif

	If Qlt == TRUE && mslVTSetBloodQuality.GetValue() >= 2
		CheckBloodQuality(akTarget, mslVTSetBloodQuality.GetValue() as Int)
	Endif

EndFunction

Function VampireFeedSus(Actor akTarget, Int FeedType = 0, Int PassOut = 0)
;Placeholder for sustained feeding, not implemented yet!
;FeedType 0 (no animations)
;FeedType 1 (dialogue animations)
;FeedType 2 (mind control animations)
EndFunction

Function CheckBloodQuality(Actor akTarget, Int Mode = 0)

	If Mode == 2
		;Apply blood addiction effects if preference is high enough
		If akTarget.GetAV("Infamy") >= AddictionThreshold.Value
			akPlayer.DispelSpell(mslVTBloodEffectsSpell)
			mslVTBloodEffectsSpell.Cast(akTarget,akPlayer)
			AddictionBar.Value = akTarget.GetAV("Infamy")
		Endif
	Endif

EndFunction

Function ApplyBloodEffects(Actor akTarget, Int Mode = 0)

EndFunction

Function VampireCure(Actor Player)

	PlayerIsVampire.SetValue(0)
	
	IncrementStat( "Vampirism Cures" )
	;Stop tracking the Feed Timer
	UnregisterforUpdate()

	VampireStatus = 0
	;Player is no longer hated
	Player.RemoveFromFaction(VampirePCFaction)
	Player.SetAttackActorOnSight(False)
	
	;Change player's race to whatever she or he was as a mortal
	if RacesVampires.HasForm(Player.GetActorBase().GetRace())
		int Index = 0
		bool RaceChanged = FALSE
		while (RaceChanged == FALSE)
			if (Player.GetActorBase().GetRace() == (RacesVampires.GetAt(Index) as Race))
;				MessageBox("Player's vampire race is " + (RacesVampires.GetAt(Index) as Race))
				Player.SetRace(Races.GetAt(Index) as Race)
;				wait(2.0)
;				MessageBox("Player's mortal race is " + (Races.GetAt(Index) as Race))
				RaceChanged = TRUE
			else
				Index += 1
			endif
		endwhile
	endif


	;Reset the experience system and remove powers
	mslVTExp.SetValue(0)
	mslVTExpLevel.SetValue(1)
	mslVTExpPoints.SetValue(0)
	mslVTAge.SetValue(0)

	int Index = 0
	while (Index < CurePowers.GetSize())
		Player.RemoveSpell(CurePowers.GetAt(Index) as Spell)
		Player.DispelSpell(CurePowers.GetAt(Index) as Spell)
		Index += 1
	endwhile

	SetPlayerAlias(FALSE)

	;Set the Global for stat tracking
	PlayerIsVampire.SetValue(0)

	RedVisionImod.Remove()

	SendModEvent("VTVampireCure")
	
	Player.SendVampirismStateChanged(false)
	
EndFunction

;Properties

Spell Property VampireCureDisease Auto

GlobalVariable Property PlayerIsVampire  Auto  

Sound  Property MagVampireTransform01  Auto  
Message Property VampireStage4Message Auto

Quest Property VC01 Auto
FormList Property CrimeFactions  Auto  

;VAMPIRIC THIRST properties

GlobalVariable Property BloodCur  Auto  
GlobalVariable Property BloodMax  Auto  
GlobalVariable Property BloodMaxMod  Auto 

GlobalVariable Property DetAct  Auto  
GlobalVariable Property DetNat  Auto  
GlobalVariable Property DetActMult  Auto  
GlobalVariable Property DetNatMult  Auto  

GlobalVariable Property BloodRatio Auto

SPELL Property HungerState1  Auto  
SPELL Property HungerState2  Auto  
SPELL Property HungerState3  Auto  
SPELL Property HungerState4  Auto  
SPELL Property HungerState5  Auto  

ImageSpaceModifier Property RedVisionImod  Auto  

GlobalVariable Property TimeScale  Auto  

Float Property Mark  Auto

SPELL Property mslVTFeedTokenControlCloak  Auto
SPELL Property BiteToken  Auto  
FormList Property FeedGlobal  Auto  
FormList Property EmptyBottles Auto
Potion Property BottledBloodPOT Auto
ImageSpaceModifier Property FeedISMD  Auto  
Spell Property mslVTFeedFaint Auto
Faction Property mslVTFeedRecoveryFAC Auto

Keyword Property Vampire Auto
GlobalVariable Property mslVTAgeDiablerieMod Auto
FormList Property NPCVampireBosses Auto

GlobalVariable Property mslVTSetBloodQuality Auto
Float Property QualityMult Auto
GlobalVariable Property PercentMult Auto
GlobalVariable Property AddictionBar Auto
GlobalVariable Property AddictionThreshold Auto

MagicEffect Property mslVTBloodAddictionME Auto
Spell Property mslVTBloodEffectsSpell Auto

GlobalVariable Property mslVTSetAppearance Auto
FormList Property Races  Auto 
FormList Property RacesVampires  Auto
ImageSpaceModifier Property FadeToBlackISMD  Auto  
ImageSpaceModifier Property FadeFromBlackISMD  Auto  
Idle Property Faint  Auto  
Sound Property DeathLoopSound  Auto  
Sound Property DeathCloseSound  Auto  
SoundCategory Property DeathSoundToMute  Auto  
Sound Property DeathSoundTransform  Auto  

GlobalVariable Property DateOfChange Auto
FormList Property AgeStages  Auto 
FormList Property AgeReq  Auto 
GlobalVariable Property mslVTAge Auto
GlobalVariable Property mslVTExp Auto
GlobalVariable Property mslVTExpMult Auto
GlobalVariable Property mslVTExpLevel Auto
GlobalVariable Property mslVTExpPoints Auto
Sound Property mslVTAdvanceSM Auto
Spell Property mslVTPSMenu Auto
Spell Property mslVTFeedAction Auto
Spell Property mslVTHotkeyControl Auto
Spell Property VampiresSightSP Auto

GlobalVariable Property mslVTUpdate Auto
Spell Property VampirePoisonResist Auto
Spell Property VampireVampirism Auto

GlobalVariable Property mslVTStoryline  Auto  

FormList Property CurePowers Auto

GlobalVariable Property mslVTSetKillEssential Auto
GlobalVariable Property mslVTSetAgeingMult Auto
GlobalVariable Property mslVTSetNPCPowers Auto
GlobalVariable Property mslVTSetDeathSceneAnim Auto

Location Property CastleVolkiharLoc Auto

GlobalVariable Property mslVTFeedDialogueSpeech Auto

ReferenceAlias Property PlayerVampireAlias  Auto  

SPELL Property VampireHuntersSight  Auto  

Race Property DLC1VampireBeastRace Auto

GlobalVariable Property mslVTFeedDelay Auto

;MESSAGES

Message Property mslVTAdvanceMSG Auto
Message Property mslVTChangeMSG Auto
Message Property mslVTFeedEssentialFailMSG Auto
Message Property mslVTFeedBottleFailMSG Auto
Message Property mslVTFeedDiablerieMSG Auto
Message Property mslVTHunFullMSG Auto

Actor Property akPlayer  Auto  
