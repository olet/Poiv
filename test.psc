Scriptname CrStr_MainScript extends Quest  

ActorBase Property CrStr_Peasant  Auto  
ActorBase Property CrStr_Beggar  Auto  
ActorBase Property CrStr_Hunter  Auto  
ActorBase Property CrStr_Mage  Auto  
ActorBase Property CrStr_Mercenary  Auto  
ActorBase Property CrStr_Merchant  Auto  
ActorBase Property CrStr_Miner  Auto  
ActorBase Property CrStr_Priest  Auto  
Faction Property CrimeFactionWhiterun Auto  
Faction Property CrimeFactionEastmarch Auto  
Faction Property CrimeFactionHaafingar Auto  
Faction Property CrimeFactionRift Auto  
Faction Property CrimeFactionReach Auto  
Faction Property CrimeFactionFalkreath Auto  
Faction Property CrimeFactionHjaalmarch Auto  
Faction Property CrimeFactionPale Auto  
Faction Property CrimeFactionWinterhold Auto  
Faction Property WIGenericCrimeFaction Auto  
Location Property WhiterunHoldLocation Auto  
Location Property EastmarchHoldLocation Auto  
Location Property HaafingarHoldLocation Auto  
Location Property RiftHoldLocation Auto  
Location Property ReachHoldLocation Auto  
Location Property FalkreathHoldLocation Auto  
Location Property HjaalmarchHoldLocation Auto  
Location Property PaleHoldLocation Auto  
Location Property WinterholdHoldLocation Auto  
GlobalVariable Property CrStr_Debug  Auto  
GlobalVariable Property CrStr_StartTime  Auto  
GlobalVariable Property CrStr_EndTime  Auto  
GlobalVariable Property SpawnMin  Auto  
GlobalVariable Property SpawnMax  Auto  
Keyword Property LocTypeCity  Auto  
Keyword Property LocTypeTown  Auto  
Keyword Property LocTypeInn  Auto 
ReferenceAlias Property CenterMarker  Auto  
STATIC Property XMarker  Auto  

actor PlayerREF
actor[] SpawnedNPC
bool CrowdSpawned = False		; Sets to True once we've spawned a crowd in for this location.
bool DelayScattering = False		; Sets to True if the Location loads but the Center Marker has not.
bool Polling = False				; Sets to True while polling to prevent multiple polls from occurring in short succession.
bool BeganPolling = False		; Sets to True once we start polling.
bool AllEnabled = False			; Sets to True once all NPCs are enabled so we don't need to keep looping.
bool AllDisabled = False			; Sets to True once all NPCs are disabled so we don't need to keep looping.
int MinDistance = -8000			; Min distance to spawn an NPC around an XMarker.
int MaxDistance = 8000			; Max distance to spawn an NPC around an XMarker.
int PlayerDistance = 2048		; Distance threshold between the player and the NPC used when relocating an NPC spawned too close to the player.
int ZOffset = 4096				; Z offset to help prevent the NPC from getting placed beneath the map somehow. Disable() / Enable() should snap the NPC to nearest navmesh anyway.
int r
int PollInterval = 1				; Poll every 1 hour in game time.

Event OnInit()
	PlayerREF = Game.GetPlayer()		; For performance reasons, since we're referencing the player so often.
EndEvent

Event OnUpdateGameTime()
	if (Polling  == False)
		if (CrStr_Debug.GetValue() == 1)
			debug.notification("Crowded Streets Periodic Polling.")
		endif

		if (GetCurrentHourOfDay() < CrStr_StartTime.GetValue() || GetCurrentHourOfDay() >= CrStr_EndTime.GetValue())
			EndSpawn()

		elseif (GetCurrentHourOfDay() >= CrStr_StartTime.GetValue()) && (GetCurrentHourOfDay() < CrStr_EndTime.GetValue())
			StartSpawn()

		endif
	endif
EndEvent

; Gets called when the event first starts, and periodically from OnUpdateGameTime().
; Performs the initial crowd NPC spawn, scattering if the Center Marker is currently loaded, and re-enables any previously spawned NPCs if gametime returns to specified hours.
Function StartSpawn()

	Polling = True



	; Spawn crowd regardless of time. Do this first when event starts.
	if (CrowdSpawned == False)

		int i = 0
		r = Utility.RandomInt(SpawnMin.GetValue() as int, SpawnMax.GetValue() as int)		; Determine the random number of NPCs to spawn.

		SpawnedNPC = new actor[50]		; Create array. Increase this number if you ever need to spawn more than 50 NPCs at a time.

		; Prevent more NPCs from being generated than we have slots in the array for. If you ever need to spawn more than 50 NPCs, change these values too.
		; Helps prevent NPCs from getting orphaned from the array, which would prevent them from getting properly deleted.
		if (r > 50)
			r = 50
		endif
		
		While (i < r)
			; Determine what kind of NPC to spawn.
			ActorBase RandomNPC
			int randomChance = Utility.RandomInt(1,20)
			if (randomChance <= 13)
				RandomNPC = CrStr_Peasant
			elseif (randomChance == 14)
				RandomNPC = CrStr_Beggar
			elseif (randomChance == 15)
				RandomNPC = CrStr_Hunter
			elseif (randomChance == 16)
				RandomNPC = CrStr_Mage
			elseif (randomChance == 17)
				RandomNPC = CrStr_Mercenary
			elseif (randomChance == 18)
				RandomNPC = CrStr_Merchant
			elseif (randomChance == 19)
				RandomNPC = CrStr_Miner
			elseif (randomChance == 20)
				RandomNPC = CrStr_Priest
			endif
			
			; Spawn NPC
			SpawnedNPC[i] = CenterMarker.GetReference().PlaceAtMe(RandomNPC, 1, False, True) as actor		; Place an initally disabled NPC at CenterMarker and add to array.

			; Add NPC to local crime faction, if possible.
			if PlayerREF.IsInLocation(WhiterunHoldLocation)
				SpawnedNPC[i].AddToFaction(CrimeFactionWhiterun)
				SpawnedNPC[i].SetCrimeFaction(CrimeFactionWhiterun)
			elseif PlayerREF.IsInLocation(EastmarchHoldLocation)
				SpawnedNPC[i].AddToFaction(CrimeFactionEastmarch)
				SpawnedNPC[i].SetCrimeFaction(CrimeFactionEastmarch)
			elseif PlayerREF.IsInLocation(HaafingarHoldLocation)
				SpawnedNPC[i].AddToFaction(CrimeFactionHaafingar)
				SpawnedNPC[i].SetCrimeFaction(CrimeFactionHaafingar)
			elseif PlayerREF.IsInLocation(RiftHoldLocation)
				SpawnedNPC[i].AddToFaction(CrimeFactionRift)
				SpawnedNPC[i].SetCrimeFaction(CrimeFactionRift)
			elseif PlayerREF.IsInLocation(ReachHoldLocation)
				SpawnedNPC[i].AddToFaction(CrimeFactionReach)
				SpawnedNPC[i].SetCrimeFaction(CrimeFactionReach)
			elseif PlayerREF.IsInLocation(FalkreathHoldLocation)
				SpawnedNPC[i].AddToFaction(CrimeFactionFalkreath)
				SpawnedNPC[i].SetCrimeFaction(CrimeFactionFalkreath)
			elseif PlayerREF.IsInLocation(HjaalmarchHoldLocation)
				SpawnedNPC[i].AddToFaction(CrimeFactionHjaalmarch)
				SpawnedNPC[i].SetCrimeFaction(CrimeFactionHjaalmarch)
			elseif PlayerREF.IsInLocation(PaleHoldLocation)
				SpawnedNPC[i].AddToFaction(CrimeFactionPale)
				SpawnedNPC[i].SetCrimeFaction(CrimeFactionPale)
			elseif PlayerREF.IsInLocation(WinterholdHoldLocation)
				SpawnedNPC[i].AddToFaction(CrimeFactionWinterhold)
				SpawnedNPC[i].SetCrimeFaction(CrimeFactionWinterhold)
			else
				SpawnedNPC[i].AddToFaction(WIGenericCrimeFaction)
				SpawnedNPC[i].SetCrimeFaction(WIGenericCrimeFaction)
			endif

			; If CenterMarker is loaded, do scattering now.
			; Slightly more performative to do this here rather than call the DoScattering() function and run a separate while loop.
			if (CenterMarker.GetReference().Is3dLoaded())
				; Move NPC to a random spot around the Center Marker.
				;SpawnedNPC[i].MoveTo(CenterMarker.GetReference(), Utility.RandomInt(MinDistance, MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), CenterMarker.GetReference().GetPositionZ() - ZOffset, False)

				; Move NPC to a random spot around a random XMarker. This should help spread NPCs out a bit better.
				SpawnedNPC[i].MoveTo(Game.FindRandomReferenceOfTypeFromRef(XMarker, CenterMarker.GetReference(), MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), PlayerREF.GetPositionZ() - ZOffset, False)

				; If NPC is too close to the player, move again.
				while (PlayerREF.GetDistance(SpawnedNPC[i]) < PlayerDistance)		; If spawned NPC is too close to player, move them again.
					;SpawnedNPC[i].MoveTo(CenterMarker.GetReference(), Utility.RandomInt(MinDistance, MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), CenterMarker.GetReference().GetPositionZ() - ZOffset, False)
					SpawnedNPC[i].MoveTo(Game.FindRandomReferenceOfTypeFromRef(XMarker, CenterMarker.GetReference(), MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), PlayerREF.GetPositionZ() - ZOffset, False)
				endwhile

				; Enable crowd if within specified hours.
				if (GetCurrentHourOfDay() >= CrStr_StartTime.GetValue()) && (GetCurrentHourOfDay() < CrStr_EndTime.GetValue())
					SpawnedNPC[i].Enable(false)		; Snap NPC to navmesh when enabled.
					AllEnabled = True
				else
					AllDisabled = True
				endif
			
			; Otherwise, do scattering later once the Center Marker has loaded. Cannot do scattering if XMarkers aren't loaded yet.
			else
				DelayScattering = True

				; Keep NPC disabled for now.

			endif

			i += 1
		EndWhile
		
		CrowdSpawned = True		; Set to True so we don't spawn them in again.

		if (CrStr_Debug.GetValue() == 1)
			debug.notification("Crowded Streets Spawned " + r + " NPCs.")
			if (DelayScattering == True)
				debug.notification("Crowded Streets NPC scattering delayed...")
			endif
		endif



	; Re-Enables the crowd NPCs if we've already spawned them in previously and they were hidden for night time.
	elseif (CrowdSpawned == True) && (AllEnabled == False)
		if (CrStr_Debug.GetValue() == 1)
			debug.notification("Crowded Streets enabling " + r + " NPCs.")
		endif
		int i = 0
		int h = 0
		While (i < r)
			if (SpawnedNPC[i].IsEnabled() == 0)

				; Only disable if the NPC is far away from the player. Otherwise, try again in an hour.
				if (PlayerREF.GetDistance(SpawnedNPC[i]) > PlayerDistance) || (PlayerREF.HasLOS(SpawnedNPC[i]) == 0)
					SpawnedNPC[i].Enable(false)					; Re-enable the NPC.
					h += 1
				EndIf
			else
				h += 1
			EndIf
			i += 1
		EndWhile

		if (h > 0)
			AllDisabled = False
		endif

		if (r == h)
			if (CrStr_Debug.GetValue() == 1)
				debug.notification("All crowd NPCs are enabled.")
				AllEnabled = True
			endif
		else
			if (CrStr_Debug.GetValue() == 1)
				debug.notification("Some crowd NPCs remain disabled for now...")
			endif
		endif

	EndIf

	; Begin periodic polling. Start this even if we're outside of specified hours.
	if (BeganPolling == False)
		BeganPolling = True
		RegisterForUpdateGameTime(PollInterval)
	endif

	Polling = False

EndFunction

; Gets called periodically from OnUpdateGameTime().
; Hides the crowd NPCs when gametime progresses to non-specified hours.
Function EndSpawn()

	Polling = True

	; Only start cleanup if we've spawned a crowd.
	if (CrowdSpawned == True) && (AllDisabled == False)
		if (CrStr_Debug.GetValue() == 1)
			debug.notification("Crowded Streets Cleanup on " + r + " NPCs.")
		endif

		int i = 0
		int h = 0
		While (i < r)
			if (SpawnedNPC[i].IsEnabled() == 1) && (SpawnedNPC[i].IsDead() == 0)		; Only do this if we haven't already cleaned this NPC up or if NPC isn't dead.

				; Only re-enable if the NPC is far away from the player. Otherwise, try again in an hour.
				if (PlayerREF.GetDistance(SpawnedNPC[i]) > PlayerDistance) || (PlayerREF.HasLOS(SpawnedNPC[i]) == 0)
					SpawnedNPC[i].Disable(false)					; Disable the NPC. Don't delete just yet, in case the player hangs around until specified hours.
					h += 1
				EndIf
			else
				h += 1
			EndIf
			
			; Cleanup dead NPCs. Commented out for now in case it interferes with above check. All crowd NPCs will still be removed when event ends.
			;if (SpawnedNPC[i].IsDead() == 1)
			;	SpawnedNPC[i].Delete()
			;endif
			i += 1
		EndWhile
		
		if (h > 0)
			AllEnabled = False
		endif
		
		if (r == h)
			if (CrStr_Debug.GetValue() == 1)
				debug.notification("All crowd NPCs have been disabled.")
				AllDisabled = True
			endif
		else
			if (CrStr_Debug.GetValue() == 1)
				debug.notification("Some crowd NPCs remain enabled for now...")
			endif
		endif

	EndIf

	Polling = False
	
EndFunction

; Delete spawned crowd NPCs when the player leaves the spawn location.
; Gets called by the script on the PlayerREF alias.
Function Cleanup()
	UnregisterForUpdateGameTime()		; Stop polling for updates.
	
	if (CrStr_Debug.GetValue() == 1)
		debug.notification("Crowded Streets Crowd Deletion on " + r + " NPCs.")
	endif
	
	if (CrowdSpawned == True)		; Only delete the NPCs if we've actually spawned them in.
		int i = 0
		While (i < r)
			SpawnedNPC[i].Delete()		; Delete the NPC.
			SpawnedNPC[i] = None		; Clear array instance to ensure NPC really is gone, as per: https://www.afkmods.com/index.php?/topic/3781-the-critter-thread/page/2/#entry149444.
			i += 1
		EndWhile
	EndIf

	SetStage(255)		; Setstage here to ensure NPCs get deleted first before ending the event.
	
EndFunction

; Called by the script on the CenterMarker alias to check whether we need to delay scattering the NPCs.
bool Function GetDelayScattering()
	return DelayScattering 
EndFunction

; Called by the script on the Center Marker alias to scatter the NPCs if they were spawned while the Center Marker wasn't loaded.
Function DoScattering()
	if (CrStr_Debug.GetValue() == 1)
		debug.notification("Crowded Streets Scattering on " + r + " NPCs.")
	endif

	int i = 0	
	While (i < r)
		; Move NPC to a random spot around the Center Marker.
		;SpawnedNPC[i].MoveTo(CenterMarker.GetReference(), Utility.RandomInt(MinDistance, MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), CenterMarker.GetReference().GetPositionZ() - ZOffset, False)

		; Move NPC to a random spot around a random XMarker. This should help spread NPCs out even more in case they get placed off the navmesh and snap back to the center marker.
		SpawnedNPC[i].MoveTo(Game.FindRandomReferenceOfTypeFromRef(XMarker, CenterMarker.GetReference(), MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), PlayerREF.GetPositionZ() - ZOffset, False)

		; If NPC is too close to the player, move again.
		while (PlayerREF.GetDistance(SpawnedNPC[i]) < PlayerDistance)		; If spawned NPC is too close to player, move them again.
			;SpawnedNPC[i].MoveTo(CenterMarker.GetReference(), Utility.RandomInt(MinDistance, MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), CenterMarker.GetReference().GetPositionZ() - ZOffset, False)
			SpawnedNPC[i].MoveTo(Game.FindRandomReferenceOfTypeFromRef(XMarker, CenterMarker.GetReference(), MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), Utility.RandomInt(MinDistance, MaxDistance), PlayerREF.GetPositionZ() - ZOffset, False)
		endwhile

		; If NPCs weren't enabled when they were spawned and we're within the specified time, enable them now.
		if (GetCurrentHourOfDay() >= CrStr_StartTime.GetValue()) && (GetCurrentHourOfDay() < CrStr_EndTime.GetValue())
			SpawnedNPC[i].Enable()		; Snap NPC to navmesh when enabled.
			AllEnabled = True
		else
			AllDisabled = True
		endif
		i += 1
		EndWhile
	DelayScattering = False
EndFunction

;Source: https://ck.uesp.net/wiki/Function_for_Time_of_Day
float Function GetCurrentHourOfDay() 

	float Time = Utility.GetCurrentGameTime()
	Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
	Time *= 24 ; Convert from fraction of a day to number of hours
	Return Time

EndFunction
