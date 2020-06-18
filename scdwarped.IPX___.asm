; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Start of IPX___.MMD file
; This is the hacked version for Sonic CD Warped.

IPX_Header:
	dc.l	$000000FF, $000003FF, IPX_RAM_Start, 0, 0, 0, 0, 0
	dc.l	0, 0, 0, 0, 0, 0, 0, 0
	dc.l	0, 0, 0, 0, 0, 0, 0, 0
	dc.l	0, 0, 0, 0, 0, 0, 0, 0
	dc.l	0, 0, 0, 0, 0, 0, 0, 0
	dc.l	0, 0, 0, 0, 0, 0, 0, 0
	dc.l	0, 0, 0, 0, 0, 0, 0, 0
	dc.l	0, 0, 0, 0, 0, 0, 0, 0
; -----------------------------------------------------------------------------

IPX_Start:
	move.l	#IPX_int_BE4-IPX_Start+IPX_RAM_Start,(V_Int_addr).w
	bsr.w	IPX_loc_D1C

	; Erases $1100 bytes starting at $0F00.
	; $0F00 -> $2000
	lea	(IPX_unk_0F00).l,a0
	move.w	#$0440-1,d7
.loop:	move.l	#0,(a0)+
	dbf	d7,.loop

	moveq	#unk_file_5,d0
	bsr.w	IPX_LoadAndRunFile
	move.w	#unk_file_89,d0
	bsr.w	IPX_LoadAndRunFile

	tst.b	d0
	beq.s	.skip
	bset	#0,(IPX_unk_0F1F).l
.skip:	bsr.w	IPX_LoadSavedData

IPX_MainLoop:
	move.w	#unk_file_86,d0
	bsr.w	IPX_loc_CE0

	moveq	#0,d0
	move.l	d0,(IPX_unk_1518).l
	move.b	d0,(IPX_unk_0F01).l
	move.b	d0,(IPX_unk_156E).l
	move.b	d0,(IPX_unk_158E).l
	move.w	d0,(IPX_unk_1512).l
	move.l	d0,(IPX_unk_1514).l
	move.b	d0,(IPX_GoodFuture_ActFlag).l
	move.b	d0,(IPX_unk_156D).l
	move.b	d0,(IPX_PreviousGameMode).l
	move.b	#present,(IPX_CurrentTimeZone).l

	moveq	#title_screen_file,d0
	bsr.w	IPX_LoadAndRunFile
	ext.w	d1
	add.w	d1,d1
	move.w	IPX_off_TitleSelection(pc,d1.w),d1
	jsr	IPX_off_TitleSelection(pc,d1.w)
	bra.s	IPX_MainLoop
; -----------------------------------------------------------------------------

IPX_off_TitleSelection:	offsetTable
			offsetTableEntry.w IPX_StartDemo
			offsetTableEntry.w IPX_NewGame
			offsetTableEntry.w IPX_Continue
			offsetTableEntry.w IPX_TimeAttack
			offsetTableEntry.w IPX_RamData
			offsetTableEntry.w IPX_DAGarden
			offsetTableEntry.w IPX_VisualMode
			offsetTableEntry.w IPX_SoundTest
			offsetTableEntry.w IPX_LevelSelect
			offsetTableEntry.w IPX_TeamRecords
; -----------------------------------------------------------------------------
; IPX_loc_A8:
IPX_TeamRecords:
	move.w	#team_records_file,d0
	bra.w	IPX_LoadAndRunFile
; -----------------------------------------------------------------------------
; IPX_loc_B0:
IPX_RamData:
	move.w	#ram_data_file,d0
	bsr.w	IPX_LoadAndRunFile
	bsr.w	IPX_LoadSavedData
	rts
; -----------------------------------------------------------------------------
; IPX_loc_BE:
IPX_SS1_Start:
	move.b	#0,(IO_SpecialStageToLoad).l
	move.b	#0,(IO_TimeStones_Array).l
	bset	#0,(IO_SpecialStage_Flags).l

	moveq	#special_stage_file,d0
	bsr.w	IPX_LoadAndRunFile
	rts
; -----------------------------------------------------------------------------
; IPX_loc_DE:
IPX_SS6_Start:
	move.b	#5,(IO_SpecialStageToLoad).l
	move.b	#0,(IO_TimeStones_Array).l
	bset	#0,(IO_SpecialStage_Flags).l

	moveq	#special_stage_file,d0
	bsr.w	IPX_LoadAndRunFile
	rts
; -----------------------------------------------------------------------------
; IPX_loc_FE:
IPX_Continue:
	bset	#0,(IPX_PreviousGameMode).l

	bsr.w	IPX_LoadSavedData
	move.w	(IPX_CurrentZoneInSave).l,(IPX_CurrentZoneAndAct).l
	move.b	#3,(IPX_unk_1508).l
	move.b	#0,(IPX_unk_151C).l

	cmpi.b	#palmtree_panic_zone,(IPX_CurrentZoneAndAct).l
	beq.w	IPX_NewGame
	cmpi.b	#collision_chaos_zone,(IPX_CurrentZoneAndAct).l
	bls.w	IPX_Continue_R3
	cmpi.b	#tidal_tempest_zone,(IPX_CurrentZoneAndAct).l
	bls.w	IPX_Continue_R4
	cmpi.b	#quartz_quadrant_zone,(IPX_CurrentZoneAndAct).l
	bls.w	IPX_Continue_R5
	cmpi.b	#wacky_workbench_zone,(IPX_CurrentZoneAndAct).l
	bls.w	IPX_Continue_R6
	cmpi.b	#stardust_speedway_zone,(IPX_CurrentZoneAndAct).l
	bls.w	IPX_Continue_R7
	cmpi.b	#metallic_madness_zone,(IPX_CurrentZoneAndAct).l
	bls.w	IPX_Continue_R8

; IPX_loc_170:
IPX_NewGame:
	bset	#0,(IPX_PreviousGameMode).l

	moveq	#0,d0
	move.b	d0,(IPX_unk_151C).l
	move.w	d0,(IPX_CurrentZoneAndAct).l
	move.w	d0,(IPX_CurrentZoneInSave).l
	move.b	d0,(IPX_GoodFuture_Array).l
	move.b	d0,(IPX_unk_0F21).l
	move.b	d0,(IPX_TimeStones_Array).l

	bsr.w	IPX_SaveData
	bsr.w	IPX_LoadAndRun_R11
	bsr.w	IPX_LoadAndRun_R12
	bsr.w	IPX_LoadAndRun_R13

	moveq	#3,d0
	bsr.w	IPX_ZoneCleanup
	bne.s	.skip
	bset	#0,(IPX_GoodFuture_Array).l
.skip:	bset	#6,(IPX_unk_0F1D).l
	bset	#5,(IPX_unk_0F1D).l

; IPX_loc_1DE:
IPX_Continue_R3:
	bsr.w	IPX_SaveData
	move.b	#0,(IPX_unk_1577).l
	bsr.w	IPX_LoadAndRun_R31
	move.b	#0,(IPX_unk_1577).l
	bsr.w	IPX_LoadAndRun_R32
	bsr.w	IPX_LoadAndRun_R33

	moveq	#6,d0
	bsr.w	IPX_ZoneCleanup
	bne.s	IPX_Continue_R4
	bset	#1,(IPX_GoodFuture_Array).l

; IPX_loc_226:
IPX_Continue_R4:
	bsr.w	IPX_SaveData
	bsr.w	IPX_LoadAndRun_R41
	bsr.w	IPX_LoadAndRun_R42
	bsr.w	IPX_LoadAndRun_R43

	moveq	#9,d0
	bsr.w	IPX_ZoneCleanup
	bne.s	IPX_Continue_R5
	bset	#2,(IPX_GoodFuture_Array).l

; IPX_loc_25E:
IPX_Continue_R5:
	bsr.w	IPX_SaveData
	bsr.w	IPX_LoadAndRun_R51
	bsr.w	IPX_LoadAndRun_R52
	bsr.w	IPX_LoadAndRun_R53

	moveq	#12,d0
	bsr.w	IPX_ZoneCleanup
	bne.s	IPX_Continue_R6
	bset	#3,(IPX_GoodFuture_Array).l

; IPX_loc_296:
IPX_Continue_R6:
	bsr.w	IPX_SaveData
	bsr.w	IPX_LoadAndRun_R61
	bsr.w	IPX_LoadAndRun_R62
	bsr.w	IPX_LoadAndRun_R63

	moveq	#15,d0
	bsr.w	IPX_ZoneCleanup
	bne.s	IPX_Continue_R7
	bset	#4,(IPX_GoodFuture_Array).l

; IPX_loc_2CE:
IPX_Continue_R7:
	bsr.w	IPX_SaveData
	bsr.w	IPX_LoadAndRun_R71
	bsr.w	IPX_LoadAndRun_R72
	bsr.w	IPX_LoadAndRun_R73

	moveq	#18,d0
	bsr.w	IPX_ZoneCleanup
	bne.s	IPX_Continue_R8
	bset	#5,(IPX_GoodFuture_Array).l

; IPX_loc_306:
IPX_Continue_R8:
	bsr.w	IPX_SaveData
	bsr.w	IPX_LoadAndRun_R81
	bsr.w	IPX_LoadAndRun_R82
	bsr.w	IPX_LoadAndRun_R83

	moveq	#21,d0
	bsr.w	IPX_ZoneCleanup
	bne.s	IPX_EndOfGame
	bset	#6,(IPX_GoodFuture_Array).l

;IPX_loc_33E:
IPX_EndOfGame:
	move.b	(IPX_GoodFuture_Array).l,(IPX_static_GoodFuture_Array).l
	move.b	(IPX_TimeStones_Array).l,(IPX_static_TimeStones_Array).l
	bsr.w	IPX_SaveData

	cmpi.b	#$7F,(IPX_static_GoodFuture_Array).l
	beq.s	IPX_GoodEnding
	cmpi.b	#$7F,(IPX_static_TimeStones_Array).l
	beq.s	IPX_GoodEnding

;IPX_loc_36A:
IPX_BadEnding:
	move.b	#0,(IPX_unk_0F24).l
	move.w	#bad_ending_file,d0
	bsr.w	IPX_LoadAndRunFile
	tst.b	(IPX_static_unk_0BE3).l
	bmi.s	IPX_BadEnding
	rts
; -----------------------------------------------------------------------------
;IPX_loc_384:
IPX_GoodEnding:
	move.b	#$7F,(IPX_unk_0F24).l
	move.w	#good_ending_file,d0
	bsr.w	IPX_LoadAndRunFile
	tst.b	(IPX_static_unk_0BE3).l
	bmi.s	IPX_GoodEnding
	rts
; -----------------------------------------------------------------------------
; Because of space limitations, functions of the Sonic CD Warped hack are scattered
; everywhere where they fit... As such, we desperately need some free bytes.
; This function alone free a lot of bytes as its code was originally copy/pasted 7 times.
IPX_ZoneCleanup:
	bsr.w	IPX_loc_5F8
	move.b	#0,(IPX_unk_158E).l
	move.b	#0,(IPX_unk_156D).l
	cmpi.b	#3,(IPX_EggMachine_ZoneFlags).l ; Eggman machine destroyed in act 1 and act 2?
	rts
; -----------------------------------------------------------------------------

IPX_RandomTimezone_Future:
	move.b	#future,(IPX_CurrentTimeZone).l
	btst	#0,d1
	beq.s	IPX_RandomTimezone_GoodFuture

IPX_RandomTimezone_BadFuture:
	bsr.s	IPX_TestAllTimeStones
	bset	#7,(IPX_TimeStones_Array).l
	move.b	#bad_future,(IPX_GoodFuture_ActFlag).l
	rts
; -----------------------------------------------------------------------------

IPX_RandomTimezone_GoodFuture:
	bsr.s	IPX_TestAllTimeStones
	move.b	#good_future,(IPX_GoodFuture_ActFlag).l
	rts
; -----------------------------------------------------------------------------

IPX_TestAllTimeStones:
	cmpi.b	#$7F,(IPX_TimeStones_Array).l
	bne.s	.ret
	move.b	#1,(IPX_EggMachine_ActFlag).l
.ret:	rts
; -----------------------------------------------------------------------------

IPX_TestMachineFlag_EndLevel:
	bclr	#7,(IPX_TimeStones_Array).l

	tst.b	(IPX_PreviousTimeZone).l
	bne.s	IPX_TestAllTimeStones.ret

	move.b	(IPX_GoodFuture_ZoneFlags).l,d0
	btst	#0,(IPX_CurrentAct).l
	bne.w	IPX_TestMachineFlag
	lsr.b	#1,d0
	bra.w	IPX_TestMachineFlag
; -----------------------------------------------------------------------------

IPX_RandomTimezone_Act3:
	cmpi.b	#3,(IPX_EggMachine_ZoneFlags).l
	bne.s	.skip
	move.b	#1,(IPX_EggMachine_ActFlag).l

.skip:	move.b	#future,(IPX_CurrentTimeZone).l
	lsr.w	#4,d1
	andi.w	#1,d1
	move.b	(a0,d1.w),d0
	tst.b	d1
	beq.s	IPX_RandomTimezone_GoodFuture
	bra.w	IPX_RandomTimezone_BadFuture
; -----------------------------------------------------------------------------
; RAM variables inside executed code
	if * > $16F56EA
		fatal "IPX___.MMD RAM variables in $03CA-$03CB are erased! $\{*} > $16F56EA"
	else
		message "IPX___.MMD RAM variables in $03CA-$03CB: $\{*} <= $16F56EA"
	endif
	org	$16F56EA

IPX_RAM_03CA:	dc.b	0
IPX_RAM_03CB:	dc.b	0
; -----------------------------------------------------------------------------
;IPX_loc_3CC:
IPX_LoadAndRun_R11:
	lea	IPX_byte_608(pc),a0
	move.w	#palmtree_panic_zone_act_1,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_3DC:
IPX_LoadAndRun_R12:
	lea	IPX_byte_608+4(pc),a0
	move.w	#palmtree_panic_zone_act_2,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_3EC:
IPX_LoadAndRun_R13:
	lea	IPX_byte_608+8(pc),a0
	move.w	#palmtree_panic_zone_act_3,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunAct_3
; -----------------------------------------------------------------------------
;IPX_loc_3FC:
IPX_LoadAndRun_R31:
	lea	IPX_byte_612(pc),a0
	move.w	#collision_chaos_zone_act_1,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_40C:
IPX_LoadAndRun_R32:
	lea	IPX_byte_612+4(pc),a0
	move.w	#collision_chaos_zone_act_2,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_41C:
IPX_LoadAndRun_R33:
	lea	IPX_byte_612+8(pc),a0
	move.w	#collision_chaos_zone_act_3,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunAct_3
; -----------------------------------------------------------------------------
;IPX_loc_42C:
IPX_LoadAndRun_R41:
	lea	IPX_byte_61C(pc),a0
	move.w	#tidal_tempest_zone_act_1,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_43C:
IPX_LoadAndRun_R42:
	lea	IPX_byte_61C+4(pc),a0
	move.w	#tidal_tempest_zone_act_2,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_44C:
IPX_LoadAndRun_R43:
	lea	IPX_byte_61C+8(pc),a0
	move.w	#tidal_tempest_zone_act_3,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunAct_3
; -----------------------------------------------------------------------------
;IPX_loc_45C:
IPX_LoadAndRun_R51:
	lea	IPX_byte_626(pc),a0
	move.w	#quartz_quadrant_zone_act_1,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_46C:
IPX_LoadAndRun_R52:
	lea	IPX_byte_626+4(pc),a0
	move.w	#quartz_quadrant_zone_act_2,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_47C:
IPX_LoadAndRun_R53:
	lea	IPX_byte_626+8(pc),a0
	move.w	#quartz_quadrant_zone_act_3,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunAct_3
; -----------------------------------------------------------------------------
;IPX_loc_48C:
IPX_LoadAndRun_R61:
	lea	IPX_byte_630(pc),a0
	move.w	#wacky_workbench_zone_act_1,(IPX_CurrentZoneAndAct).l
	bra.s	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_49A:
IPX_LoadAndRun_R62:
	lea	IPX_byte_630+4(pc),a0
	move.w	#wacky_workbench_zone_act_2,(IPX_CurrentZoneAndAct).l
	bra.s	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_4A8:
IPX_LoadAndRun_R63:
	lea	IPX_byte_630+8(pc),a0
	move.w	#wacky_workbench_zone_act_3,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunAct_3
; -----------------------------------------------------------------------------
;IPX_loc_4B8:
IPX_LoadAndRun_R71:
	lea	IPX_byte_63A(pc),a0
	move.w	#stardust_speedway_zone_act_1,(IPX_CurrentZoneAndAct).l
	bra.s	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_4C6:
IPX_LoadAndRun_R72:
	lea	IPX_byte_63A+4(pc),a0
	move.w	#stardust_speedway_zone_act_2,(IPX_CurrentZoneAndAct).l
	bra.s	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_4D4:
IPX_LoadAndRun_R73:
	lea	IPX_byte_63A+8(pc),a0
	move.w	#stardust_speedway_zone_act_3,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunAct_3
; -----------------------------------------------------------------------------
;IPX_loc_4E4:
IPX_LoadAndRun_R81:
	lea	IPX_byte_644(pc),a0
	move.w	#metallic_madness_zone_act_1,(IPX_CurrentZoneAndAct).l
	bra.s	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_4F2:
IPX_LoadAndRun_R82:
	lea	IPX_byte_644+4(pc),a0
	move.w	#metallic_madness_zone_act_2,(IPX_CurrentZoneAndAct).l
	bra.s	IPX_RunActs_1_2
; -----------------------------------------------------------------------------
;IPX_loc_500:
IPX_LoadAndRun_R83:
	lea	IPX_byte_644+8(pc),a0
	move.w	#metallic_madness_zone_act_3,(IPX_CurrentZoneAndAct).l
	bra.w	IPX_RunAct_3
; -----------------------------------------------------------------------------
; IPX_loc_510:
IPX_RunActs_1_2:
	bsr.w	IPX_RandomTimezone
	move.b	(IPX_CurrentTimeZone).l,(IPX_PreviousTimeZone).l
	andi.b	#3,(IPX_PreviousTimeZone).l
	bsr.w	IPX_LoadAndRunFile

	tst.b	(IPX_unk_1508).l
	beq.s	IPX_loc_55E
	btst	#7,(IPX_CurrentTimeZone).l
	beq.s	IPX_loc_55E

	; Warp (cutscene disabled)
	bset	#2,(IPX_PreviousGameMode).l
	bra.s	IPX_RunActs_1_2
; -----------------------------------------------------------------------------

IPX_loc_55E:
	tst.b	(IPX_unk_1508).l
	bne.s	IPX_loc_56C
	; Game over
	bra.s	IPX_RunAct_GameOver
; -----------------------------------------------------------------------------

IPX_loc_56C:
	tst.b	(IPX_unk_156E).l
	bne.s	IPX_loc_576
	; End of act
	bset	#1,(IPX_PreviousGameMode).l
	bra.w	IPX_TestMachineFlag_EndLevel
; -----------------------------------------------------------------------------

IPX_loc_576: 
	; Special stage
	bset	#1,(IPX_PreviousGameMode).l
	bsr.w	IPX_TestMachineFlag_EndLevel

	cmpi.b	#$7F,(IPX_TimeStones_Array).l
	beq.w	IPX_SecretSpecialStage

	move.b	(IPX_unk_0F21).l,(IO_SpecialStageToLoad).l
	move.b	(IPX_TimeStones_Array).l,(IO_TimeStones_Array).l
	bclr	#0,(IO_SpecialStage_Flags).l

	moveq	#special_stage_file,d0
	bsr.w	IPX_LoadAndRunFile

	move.b	#1,(IPX_unk_0F22).l
	cmpi.b	#$7F,(IPX_TimeStones_Array).l
	bne.s	IPX_loc_5B2
	move.b	#good_future,(IPX_GoodFuture_ActFlag).l

IPX_loc_5B2:
	rts
; -----------------------------------------------------------------------------
; IPX_loc_5B4:
IPX_RunAct_3:
	bsr.w	IPX_RandomTimezone
	bsr.w	IPX_LoadAndRunFile

	tst.b	(IPX_unk_1508).l
	bne.s	IPX_loc_5D8

IPX_RunAct_GameOver:
	; Game over
	move.l	(sp)+,d0
	bra.w	IPX_loc_39E
; -----------------------------------------------------------------------------

IPX_loc_5D8:
	; End of act
	bclr	#7,(IPX_TimeStones_Array).l
	bset	#1,(IPX_PreviousGameMode).l
	addq.b	#1,(IPX_CurrentZoneInSave).l
	cmpi.b	#7,(IPX_CurrentZoneInSave).l
	bcs.s	IPX_loc_5EE
	subq.b	#1,(IPX_CurrentZoneInSave).l

IPX_loc_5EE:
	move.b	#0,(IPX_unk_158E).l
	rts
; -----------------------------------------------------------------------------

IPX_loc_39E:
	move.b	#0,(IPX_CurrentAct).l
	move.w	(IPX_CurrentZoneAndAct).l,(IPX_CurrentZoneInSave).l

	move.b	#0,(IPX_unk_158E).l
	move.b	#0,(IPX_unk_156D).l
	move.b	#bad_future,(IPX_GoodFuture_ActFlag).l
	rts
; -----------------------------------------------------------------------------

IPX_loc_5F8:
	cmp.b	(IPX_unk_0F18).l,d0
	bls.s	IPX_byte_606
	move.b	d0,(IPX_unk_0F18).l

IPX_byte_606:
	rts
; -----------------------------------------------------------------------------

IPX_byte_608:
	dc.b	R11A_file, R11B_file, R11C_file, R11D_file
	dc.b	R12A_file, R12B_file, R12C_file, R12D_file
	dc.b	R13C_file, R13D_file
IPX_byte_612:
	dc.b	R31A_file, R31B_file, R31C_file, R31D_file
	dc.b	R32A_file, R32B_file, R32C_file, R32D_file
	dc.b	R33C_file, R33D_file
IPX_byte_61C:
	dc.b	R41A_file, R41B_file, R41C_file, R41D_file
	dc.b	R42A_file, R42B_file, R42C_file, R42D_file
	dc.b	R43C_file, R43D_file
IPX_byte_626:
	dc.b	R51A_file, R51B_file, R51C_file, R51D_file
	dc.b	R52A_file, R52B_file, R52C_file, R52D_file
	dc.b	R53C_file, R53D_file
IPX_byte_630:
	dc.b	R61A_file, R61B_file, R61C_file, R61D_file
	dc.b	R62A_file, R62B_file, R62C_file, R62D_file
	dc.b	R63C_file, R63D_file
IPX_byte_63A:
	dc.b	R71A_file, R71B_file, R71C_file, R71D_file
	dc.b	R72A_file, R72B_file, R72C_file, R72D_file
	dc.b	R73C_file, R73D_file
IPX_byte_644:
	dc.b	R81A_file, R81B_file, R81C_file, R81D_file
	dc.b	R82A_file, R82B_file, R82C_file, R82D_file
	dc.b	R83C_file, R83D_file
; -----------------------------------------------------------------------------

IPX_RandomTimezone:
	moveq	#0,d0
	move.b	(IPX_PreviousGameMode).l,d0
	move.b	#0,(IPX_PreviousGameMode).l
	btst	#2,d0
	bne.w	IPX_RandomTimezone_Warp
	move.b	#0,(IPX_EggMachine_ActFlag).l
	btst	#1,d0
	bne.s	.level

;.titleScreen:
	move.w	(FramesCounter).w,d1
	bra.s	.acts_1_2
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

.level:
	move.w	(IPX_FramesCounter_Level).l,d1
	btst	#1,(IPX_CurrentAct).l
	bne.w	IPX_RandomTimezone_Act3

.acts_1_2:
	lsl.w	(IPX_EggMachine_ZoneFlags).l
	lsr.w	#4,d1
	andi.w	#3,d1
	move.b	(a0,d1.w),d0

	cmpi.b	#1,d1
	blt.s	IPX_RandomTimezone_Present
	beq.s	IPX_RandomTimezone_Past
	bra.w	IPX_RandomTimezone_Future
; -----------------------------------------------------------------------------

IPX_RandomTimezone_Present:
	move.b	#present,(IPX_CurrentTimeZone).l
	rts
; -----------------------------------------------------------------------------

IPX_RandomTimezone_Past:
	move.b	#past,(IPX_CurrentTimeZone).l
	rts
; -----------------------------------------------------------------------------
; CD-ROM section interleaved with the code.
	if * > $16F5A20
		fatal "IPX___.MMD CD-ROM section is erased! $\{*} > $16F5A20"
	else
		message "IPX___.MMD CD-ROM section: $\{*} <= $16F5A20"
	endif

	org		$16F5A20
	BINCLUDE	"scd.IPX___.cd_section.bin"

	; Pretend that the CD-ROM section doesn't exist
	phase		$16F5A20
; -----------------------------------------------------------------------------
; IPX_loc_64E:
IPX_LevelSelect:
	moveq	#level_select_file,d0
	bsr.w	IPX_LoadAndRunFile

	mulu.w	#6,d0
	move.w	IPX_byte_68A+2(pc,d0.w),(IPX_CurrentZoneAndAct).l
	move.b	IPX_byte_68A+4(pc,d0.w),(IPX_CurrentTimeZone).l
	move.b	IPX_byte_68A+5(pc,d0.w),(IPX_GoodFuture_ActFlag).l
	move.w	IPX_byte_68A(pc,d0.w),d0
	move.b	#0,(IPX_unk_156D).l

	cmpi.w	#special_stage_file,d0
	beq.w	IPX_SS1_Start
	bsr.w	IPX_LoadAndRunFile
	rts
;-----------------------------------------------------------------------------

ipx_68A_macro	macro	word1,word2,byte1,byte2
	dc.w	word1
	dc.w	word2
	dc.b	byte1
	dc.b	byte2
	endm

IPX_byte_68A:
	ipx_68A_macro	  R11A_file,    palmtree_panic_zone_act_1, present,  bad_future
	ipx_68A_macro	  R11B_file,    palmtree_panic_zone_act_1,    past,  bad_future
	ipx_68A_macro	  R11C_file,    palmtree_panic_zone_act_1,  future, good_future
	ipx_68A_macro	  R11D_file,    palmtree_panic_zone_act_1,  future,  bad_future
	ipx_68A_macro	  R12A_file,    palmtree_panic_zone_act_2, present,  bad_future
	ipx_68A_macro	  R12B_file,    palmtree_panic_zone_act_2,    past,  bad_future
	ipx_68A_macro	  R12C_file,    palmtree_panic_zone_act_2,  future, good_future
	ipx_68A_macro	  R12D_file,    palmtree_panic_zone_act_2,  future,  bad_future
	ipx_68A_macro	  warp_file,                            0,       0,           0
	ipx_68A_macro	intro_video_file,                       0,       0,           0
	ipx_68A_macro	comin_soon_file,                        0,       0,           0
	ipx_68A_macro	  R31A_file,   collision_chaos_zone_act_1, present,  bad_future
	ipx_68A_macro	  R31B_file,   collision_chaos_zone_act_1,    past,  bad_future
	ipx_68A_macro	  R31C_file,   collision_chaos_zone_act_1,  future, good_future
	ipx_68A_macro	  R31D_file,   collision_chaos_zone_act_1,  future,  bad_future
	ipx_68A_macro	  R32A_file,   collision_chaos_zone_act_2, present,  bad_future
	ipx_68A_macro	  R32B_file,   collision_chaos_zone_act_2,    past,  bad_future
	ipx_68A_macro	  R32C_file,   collision_chaos_zone_act_2,  future, good_future
	ipx_68A_macro	  R32D_file,   collision_chaos_zone_act_2,  future,  bad_future
	ipx_68A_macro	  R33C_file,   collision_chaos_zone_act_3,  future, good_future
	ipx_68A_macro	  R33D_file,   collision_chaos_zone_act_3,  future,  bad_future
	ipx_68A_macro	  R13C_file,    palmtree_panic_zone_act_3,  future, good_future
	ipx_68A_macro	  R13D_file,    palmtree_panic_zone_act_3,  future,  bad_future
	ipx_68A_macro	  R41A_file,     tidal_tempest_zone_act_1, present,  bad_future
	ipx_68A_macro	  R41B_file,     tidal_tempest_zone_act_1,    past,  bad_future
	ipx_68A_macro	  R41C_file,     tidal_tempest_zone_act_1,  future, good_future
	ipx_68A_macro	  R41D_file,     tidal_tempest_zone_act_1,  future,  bad_future
	ipx_68A_macro	  R42A_file,     tidal_tempest_zone_act_2, present,  bad_future
	ipx_68A_macro	  R42B_file,     tidal_tempest_zone_act_2,    past,  bad_future
	ipx_68A_macro	  R42C_file,     tidal_tempest_zone_act_2,  future, good_future
	ipx_68A_macro	  R42D_file,     tidal_tempest_zone_act_2,  future,  bad_future
	ipx_68A_macro	  R43C_file,     tidal_tempest_zone_act_3,  future, good_future
	ipx_68A_macro	  R43D_file,     tidal_tempest_zone_act_3,  future,  bad_future
	ipx_68A_macro	  R51A_file,   quartz_quadrant_zone_act_1, present,  bad_future
	ipx_68A_macro	  R51B_file,   quartz_quadrant_zone_act_1,    past,  bad_future
	ipx_68A_macro	  R51C_file,   quartz_quadrant_zone_act_1,  future, good_future
	ipx_68A_macro	  R51D_file,   quartz_quadrant_zone_act_1,  future,  bad_future
	ipx_68A_macro	  R52A_file,   quartz_quadrant_zone_act_2, present,  bad_future
	ipx_68A_macro	  R52B_file,   quartz_quadrant_zone_act_2,    past,  bad_future
	ipx_68A_macro	  R52C_file,   quartz_quadrant_zone_act_2,  future, good_future
	ipx_68A_macro	  R52D_file,   quartz_quadrant_zone_act_2,  future,  bad_future
	ipx_68A_macro	  R53C_file,   quartz_quadrant_zone_act_3,  future, good_future
	ipx_68A_macro	  R53D_file,   quartz_quadrant_zone_act_3,  future,  bad_future
	ipx_68A_macro	  R61A_file,   wacky_workbench_zone_act_1, present,  bad_future
	ipx_68A_macro	  R61B_file,   wacky_workbench_zone_act_1,    past,  bad_future
	ipx_68A_macro	  R61C_file,   wacky_workbench_zone_act_1,  future, good_future
	ipx_68A_macro	  R61D_file,   wacky_workbench_zone_act_1,  future,  bad_future
	ipx_68A_macro	  R62A_file,   wacky_workbench_zone_act_2, present,  bad_future
	ipx_68A_macro	  R62B_file,   wacky_workbench_zone_act_2,    past,  bad_future
	ipx_68A_macro	  R62C_file,   wacky_workbench_zone_act_2,  future, good_future
	ipx_68A_macro	  R62D_file,   wacky_workbench_zone_act_2,  future,  bad_future
	ipx_68A_macro	  R63C_file,   wacky_workbench_zone_act_3,  future, good_future
	ipx_68A_macro	  R63D_file,   wacky_workbench_zone_act_3,  future,  bad_future
	ipx_68A_macro	  R71A_file, stardust_speedway_zone_act_1, present,  bad_future
	ipx_68A_macro	  R71B_file, stardust_speedway_zone_act_1,    past,  bad_future
	ipx_68A_macro	  R71C_file, stardust_speedway_zone_act_1,  future, good_future
	ipx_68A_macro	  R71D_file, stardust_speedway_zone_act_1,  future,  bad_future
	ipx_68A_macro	  R72A_file, stardust_speedway_zone_act_2, present,  bad_future
	ipx_68A_macro	  R72B_file, stardust_speedway_zone_act_2,    past,  bad_future
	ipx_68A_macro	  R72C_file, stardust_speedway_zone_act_2,  future, good_future
	ipx_68A_macro	  R72D_file, stardust_speedway_zone_act_2,  future,  bad_future
	ipx_68A_macro	  R73C_file, stardust_speedway_zone_act_3,  future, good_future
	ipx_68A_macro	  R73D_file, stardust_speedway_zone_act_3,  future,  bad_future
	ipx_68A_macro	  R81A_file,  metallic_madness_zone_act_1, present,  bad_future
	ipx_68A_macro	  R81B_file,  metallic_madness_zone_act_1,    past,  bad_future
	ipx_68A_macro	  R81C_file,  metallic_madness_zone_act_1,  future, good_future
	ipx_68A_macro	  R81D_file,  metallic_madness_zone_act_1,  future,  bad_future
	ipx_68A_macro	  R82A_file,  metallic_madness_zone_act_2, present,  bad_future
	ipx_68A_macro	  R82B_file,  metallic_madness_zone_act_2,    past,  bad_future
	ipx_68A_macro	  R82C_file,  metallic_madness_zone_act_2,  future, good_future
	ipx_68A_macro	  R82D_file,  metallic_madness_zone_act_2,  future,  bad_future
	ipx_68A_macro	  R83C_file,  metallic_madness_zone_act_3,  future, good_future
	ipx_68A_macro	  R83D_file,  metallic_madness_zone_act_3,  future,  bad_future
	ipx_68A_macro	special_stage_file,                     0,       0,           0
	ipx_68A_macro	  R11A_file,    palmtree_panic_zone_act_1, present,  bad_future
	ipx_68A_macro	  R11A_file,    palmtree_panic_zone_act_1, present,  bad_future
	ipx_68A_macro	  R11A_file,    palmtree_panic_zone_act_1, present,  bad_future
	ipx_68A_macro	  R11A_file,    palmtree_panic_zone_act_1, present,  bad_future
; -----------------------------------------------------------------------------
; IPX_loc_85E:
IPX_StartDemo:
	moveq	#5,d1
	lea	(IPX_unk_0F1C).l,a6
	moveq	#0,d0
	move.b	(a6),d0
	addq.b	#1,(a6)
	cmp.b	(a6),d1
	bcc.s	IPX_loc_874
	move.b	#0,(a6)

IPX_loc_874:
	add.w	d0,d0
	move.w	IPX_off_Demo(pc,d0.w),d0
	jmp	IPX_off_Demo(pc,d0.w)
; -----------------------------------------------------------------------------
; IPX_off_87E:
IPX_off_Demo:	offsetTable
		offsetTableEntry.w IPX_IntroVideo
		offsetTableEntry.w IPX_R1_Demo
		offsetTableEntry.w IPX_SS1_Demo
		offsetTableEntry.w IPX_R4_Demo
		offsetTableEntry.w IPX_SS6_Demo
		offsetTableEntry.w IPX_R8_Demo
; -----------------------------------------------------------------------------
; IPX_loc_88A:
IPX_R1_Demo:
	move.b	#0,(IPX_unk_151C).l
	move.w	#palmtree_panic_zone_act_1,(IPX_CurrentZoneAndAct).l
	move.b	#present,(IPX_CurrentTimeZone).l
	move.b	#bad_future,(IPX_GoodFuture_ActFlag).l

	move.w	#R1_demo_file,d0
	bsr.w	IPX_LoadAndRunFile

	move.w	#0,(IPX_unk_1580).l
	rts
; -----------------------------------------------------------------------------
; IPX_loc_8BC:
IPX_R4_Demo:
	move.b	#0,(IPX_unk_151C).l
	move.w	#tidal_tempest_zone_act_3,(IPX_CurrentZoneAndAct).l
	move.b	#future,(IPX_CurrentTimeZone).l
	move.b	#good_future,(IPX_GoodFuture_ActFlag).l

	move.w	#R4_demo_file,d0
	bsr.w	IPX_LoadAndRunFile

	move.w	#0,(IPX_unk_1580).l
	rts
; -----------------------------------------------------------------------------
; IPX_loc_8EE:
IPX_R8_Demo:
	move.b	#0,(IPX_unk_151C).l
	move.w	#metallic_madness_zone_act_2,(IPX_CurrentZoneAndAct).l
	move.b	#present,(IPX_CurrentTimeZone).l
	move.b	#bad_future,(IPX_GoodFuture_ActFlag).l

	move.w	#R8_demo_file,d0
	bsr.w	IPX_LoadAndRunFile

	move.w	#0,(IPX_unk_1580).l
	rts
; -----------------------------------------------------------------------------
; IPX_loc_920:
IPX_SS1_Demo:
	move.w	#unk_file_8A,d0
	bsr.w	IPX_loc_CE0
	bra.w	IPX_SS1_Start
; -----------------------------------------------------------------------------
; IPX_loc_92C:
IPX_SS6_Demo:
	move.w	#unk_file_8A,d0
	bsr.w	IPX_loc_CE0
	bra.w	IPX_SS6_Start
; -----------------------------------------------------------------------------
; IPX_loc_938:
IPX_IntroVideo:
	move.w	#intro_video_file,d0
	bsr.w	IPX_LoadAndRunFile
	tst.b	(IPX_static_unk_0BE3).l
	bmi.s	IPX_IntroVideo
	rts
; -----------------------------------------------------------------------------
; IPX_loc_94A:
IPX_SoundTest:
	moveq	#sound_test_file,d0
	bsr.w	IPX_LoadAndRunFile

	add.w	d0,d0
	move.w	IPX_off_95A(pc,d0.w),d0
	jmp	IPX_off_95A(pc,d0.w)
; -----------------------------------------------------------------------------

IPX_off_95A:	offsetTable
		offsetTableEntry.w IPX_loc_968
		offsetTableEntry.w IPX_loc_96A
		offsetTableEntry.w IPX_loc_9A2
		offsetTableEntry.w IPX_loc_9AA
		offsetTableEntry.w IPX_loc_9B2
		offsetTableEntry.w IPX_loc_9BA
		offsetTableEntry.w IPX_loc_9C2
; -----------------------------------------------------------------------------

IPX_loc_968:
	rts
; -----------------------------------------------------------------------------

IPX_loc_96A:
	move.b	#7,(IO_SpecialStageToLoad).l
	move.b	#0,(IO_TimeStones_Array).l
	bset	#0,(IO_SpecialStage_Flags).l
	bset	#2,(IO_SpecialStage_Flags).l

	moveq	#special_stage_file,d0
	bsr.w	IPX_LoadAndRunFile

	tst.b	(IPX_unk_0F25).l
	bne.s	IPX_loc_9A0

	move.w	#secret2_file,d0
	bsr.w	IPX_LoadAndRunFile

IPX_loc_9A0:
	rts
; -----------------------------------------------------------------------------

IPX_loc_9A2:
	move.w	#secret1_file,d0
	bra.w	IPX_LoadAndRunFile
; -----------------------------------------------------------------------------

IPX_loc_9AA:
	move.w	#secret3_file,d0
	bra.w	IPX_LoadAndRunFile
; -----------------------------------------------------------------------------

IPX_loc_9B2:
	move.w	#secret4_file,d0
	bra.w	IPX_LoadAndRunFile
; -----------------------------------------------------------------------------

IPX_loc_9BA:
	move.w	#secret5_file,d0
	bra.w	IPX_LoadAndRunFile
; -----------------------------------------------------------------------------

IPX_loc_9C2:
	move.w	#secret6_file,d0
	bra.w	IPX_LoadAndRunFile
; -----------------------------------------------------------------------------
; IPX_loc_9CA:
IPX_VisualMode:
	move.w	#visual_mode_file,d0
	bsr.w	IPX_LoadAndRunFile

	add.w	d0,d0
	move.w	IPX_off_9DC(pc,d0.w),d0
	jmp	IPX_off_9DC(pc,d0.w)
; -----------------------------------------------------------------------------

IPX_off_9DC:	offsetTable
		offsetTableEntry.w IPX_loc_9F8
		offsetTableEntry.w IPX_loc_9E6
		offsetTableEntry.w IPX_loc_A0C
		offsetTableEntry.w IPX_loc_A2E
		offsetTableEntry.w IPX_loc_9FA
; -----------------------------------------------------------------------------

IPX_loc_9E6:
	move.w	#intro_video_file,d0
	bsr.w	IPX_LoadAndRunFile

	tst.b	(IPX_static_unk_0BE3).l
	bmi.s	IPX_loc_9E6
	bra.s	IPX_VisualMode
; -----------------------------------------------------------------------------

IPX_loc_9F8:
	rts
; -----------------------------------------------------------------------------

IPX_loc_9FA:
	move.w	#pencil_test_file,d0
	bsr.w	IPX_LoadAndRunFile

	tst.b	(IPX_static_unk_0BE3).l
	bmi.s	IPX_loc_9FA
	bra.s	IPX_VisualMode
; -----------------------------------------------------------------------------

IPX_loc_A0C:
	move.b	#$7F,(IPX_unk_0F24).l
	move.w	#good_ending_file,d0
	bsr.w	IPX_LoadAndRunFile

	tst.b	(IPX_static_unk_0BE3).l
	bmi.s	IPX_loc_A0C

	move.w	#player_name_file,d0
	bsr.w	IPX_LoadAndRunFile
	bra.s	IPX_VisualMode
; -----------------------------------------------------------------------------

IPX_loc_A2E:
	move.b	#0,(IPX_unk_0F24).l
	move.w	#bad_ending_file,d0
	bsr.w	IPX_LoadAndRunFile

	tst.b	(IPX_static_unk_0BE3).l
	bmi.s	IPX_loc_A2E
	bra.s	IPX_VisualMode
; -----------------------------------------------------------------------------
; IPX_loc_A48:
IPX_DAGarden:
	move.w	#d_a_garden_file,d0
	bra.w	IPX_LoadAndRunFile
; -----------------------------------------------------------------------------
; IPX_loc_A50:
IPX_TimeAttack:
	moveq	#time_attack_file,d0
	bsr.w	IPX_LoadAndRunFile

	move.w	d0,(IPX_unk_0F14).l
	beq.w	IPX_loc_AB2

	move.b	IPX_byte_AB4(pc,d0.w),d0
	bmi.s	IPX_loc_AD2

	mulu.w	#6,d0
	lea	IPX_byte_68A(pc),a6
	move.w	2(a6,d0.w),(IPX_CurrentZoneAndAct).l
	move.b	4(a6,d0.w),(IPX_CurrentTimeZone).l
	move.b	5(a6,d0.w),(IPX_GoodFuture_ActFlag).l
	move.w	(a6,d0.w),d0

	move.b	#1,(IPX_unk_0F01).l
	move.b	#0,(IPX_unk_156D).l
	bsr.w	IPX_LoadAndRunFile

	move.b	#0,(IPX_unk_158E).l
	move.l	(IPX_unk_1514).l,(IPX_unk_0F10).l
	bra.s	IPX_TimeAttack
; -----------------------------------------------------------------------------

IPX_loc_AB2:
	rts
; -----------------------------------------------------------------------------

IPX_byte_AB4:
	dc.b	  0,   0,   4, $16,  $B,  $F, $14, $17
	dc.b	$1B, $20, $21, $25, $2A, $2B, $2F, $34
	dc.b	$35, $39, $3E, $3F, $43, $48, $FF, $FE
	dc.b	$FD, $FC, $FB, $FA, $F9, $00
; -----------------------------------------------------------------------------

IPX_loc_AD2:
	neg.b	d0
	ext.w	d0
	subq.w	#1,d0
	move.b	d0,(IO_SpecialStageToLoad).l
	move.b	#0,(IO_TimeStones_Array).l
	bset	#1,(IO_SpecialStage_Flags).l

	moveq	#special_stage_file,d0
	bsr.w	IPX_LoadAndRunFile
	bra.w	IPX_TimeAttack
; -----------------------------------------------------------------------------

IPX_loc_D1C:
	bset	#1,(IO_unk_A12003).l
	btst	#1,(IO_unk_A12003).l
	beq.s	IPX_loc_D1C
	rts
; -----------------------------------------------------------------------------

IPX_TestMachineFlag:
	btst	#0,d0
	beq.s	.skip
	bset	#0,(IPX_EggMachine_ZoneFlags).l
	move.b	#1,(IPX_EggMachine_ActFlag).l
.skip:	rts
; -----------------------------------------------------------------------------

IPX_TestMachineFlag_Warp:
	move.b	(IPX_GoodFuture_ActFlag).l,d0
	bra.w	IPX_TestMachineFlag
; -----------------------------------------------------------------------------
; RAM variables inside executed code
	dephase
	if * > $16F6032
		fatal "IPX___.MMD RAM variables in $0BE2-$0BE3 are erased! $\{*} > $16F6032"
	else
		message "IPX___.MMD RAM variables in $0BE2-$0BE3: $\{*} <= $16F6032"
	endif
	org	$16F6032
	phase	$16F6032-$130

IPX_RAM_0BE2:	dc.b	0
IPX_RAM_0BE3:	dc.b	0
; -----------------------------------------------------------------------------

IPX_LoadAndRunFile:
	move.l	a0,-(sp)
	move.w	d0,(IO_unk_A12010).l

	; Erases $36C0 bytes starting at $2000.
	; $2000 -> $56C0
	lea	(IPX_unk_2000).l,a1
	moveq	#0,d0
	move.w	#$0DB0-1,d7
.loop1	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	dbf	d7,.loop1
	bsr.w	IPX_loc_D10

	move.l	(MMD_unk_200008).l,d0
	beq.w	IPX_loc_BDE
	movea.l	d0,a0

	move.l	(MMD_unk_200002).l,d0
	beq.s	IPX_loc_B44
	movea.l	d0,a2

	lea	(MMD_unk_200100).l,a1
	move.w	(MMD_unk_200006).l,d7
.loop2	move.l	(a1)+,(a2)+
	dbf	d7,.loop2

IPX_loc_B44:
	move.w	sr,-(sp)
	move.l	(MMD_unk_20000C).l,d0
	beq.s	IPX_loc_B52
	move.l	d0,(H_Int_addr).w

IPX_loc_B52:
	move.l	(MMD_unk_200010).l,d0
	beq.s	IPX_loc_B5E
	move.l	d0,(V_Int_addr).w

IPX_loc_B5E:
	btst	#6,(MMD_unk_200000).l
	beq.s	IPX_loc_B6C
	bsr.w	IPX_loc_D1C

IPX_loc_B6C:
	move.w	(sp)+,sr

IPX_loc_B6E:
	move.w	(IO_unk_A12020).l,d0
	beq.s	IPX_loc_B6E
	cmp.w	(IO_unk_A12020).l,d0
	bne.s	IPX_loc_B6E

	move.w	#0,(IO_unk_A12010).l

IPX_loc_B86:
	move.w	(IO_unk_A12020).l,d0
	bne.s	IPX_loc_B86
	move.w	(IO_unk_A12020).l,d0
	bne.s	IPX_loc_B86

	jsr	(a0)

	move.b	d0,(IPX_static_unk_0BE3).l
	bsr.w	IPX_loc_D30

	move.b	#$E0,(IO_unk_A01C0A).l
	bsr.w	IPX_loc_D4E

	move.b	#0,(IPX_unk_0F00).l
	move.l	#IPX_int_C06-IPX_Start+IPX_RAM_Start,(H_Int_addr).w
	move.l	#IPX_int_BE4-IPX_Start+IPX_RAM_Start,(V_Int_addr).w
	move.w	#$8134,(IPX_unk_0F16).l
	bset	#0,(IPX_unk_0BE2).l
	bsr.w	IPX_loc_D5E
	bsr.w	IPX_loc_D1C

IPX_loc_BDE:
	movea.l	(sp)+,a0
	rts
; -----------------------------------------------------------------------------

IPX_int_BE4:
	bset	#0,(IO_unk_A12000).l
	bclr	#0,(IPX_unk_0F00).l
	bclr	#0,(IPX_unk_0BE2).l
	beq.s	IPX_int_C06
	move.w	#$8134,(VDP_control_port).l

IPX_int_C06:
	rte
; -----------------------------------------------------------------------------

; IPX_loc_C08:
IPX_LoadSavedData:
	bsr.w	IPX_loc_C58

	move.w	(BRAM_unk_2002A4).l,(IPX_CurrentZoneInSave).l
	move.b	(BRAM_GoodFuture_Array).l,(IPX_GoodFuture_Array).l
	move.b	(BRAM_unk_2002A8).l,(IPX_unk_0F1D).l
	move.b	(BRAM_unk_2002A5).l,(IPX_unk_0F18).l
	move.b	(BRAM_unk_2002A6).l,(IPX_unk_0F19).l
	move.b	(BRAM_unk_2002AC).l,(IPX_unk_0F21).l
	move.b	(BRAM_TimeStones_Array).l,(IPX_TimeStones_Array).l
	bsr.w	IPX_loc_D1C
	rts
; -----------------------------------------------------------------------------

IPX_loc_C58:
	bsr.w	IPX_loc_D1C

	move.w	#unk_file_8B,d0
	btst	#0,(IPX_unk_0F1F).l
	bne.s	IPX_loc_C6E
	move.w	#unk_file_87,d0

IPX_loc_C6E:
	bsr.w	IPX_loc_CE0
	bra.w	IPX_loc_D10
; -----------------------------------------------------------------------------

IPX_RandomTimezone_Warp_FromFuture:
	bclr	#1,d1
	move.b	(a0,d1.w),d0
	bchg	#0,d1
	move.b	d1,(IPX_CurrentTimeZone).l

	bclr	#7,(IPX_TimeStones_Array).l
	move.b	#bad_future,(IPX_GoodFuture_ActFlag).l
	btst	#0,(IPX_EggMachine_ZoneFlags).l
	bne.w	IPX_RandomTimezone_GoodFuture
	rts
; -----------------------------------------------------------------------------

IPX_SecretSpecialStage:
	bsr.w	IPX_loc_96A
	move.b	#1,(IPX_unk_0F22).l
	move.b	#0,(IPX_unk_156E).l
	rts
; -----------------------------------------------------------------------------
; RAM variable inside executed code
	dephase
	if * > $16F61F6
		fatal "IPX___.MMD RAM variable in $0DA6 is erased! $\{*} > $16F61F6"
	else
		message "IPX___.MMD RAM variable in $0DA6: $\{*} <= $16F61F6"
	endif
	org	$16F61F6
	phase	$16F61F6-$130

IPX_RAM_0DA6:	dc.w	0
; -----------------------------------------------------------------------------

; IPX_loc_C76:
IPX_SaveData:
	move.b	#bad_future,(IPX_GoodFuture_ActFlag).l
	move.b	#0,(IPX_EggMachine_ZoneFlags).l
	bsr.s	IPX_loc_C58 

	move.w	(IPX_CurrentZoneInSave).l,(BRAM_unk_2002A4).l
	move.b	(IPX_GoodFuture_Array).l,(BRAM_GoodFuture_Array).l
	move.b	(IPX_unk_0F1D).l,(BRAM_unk_2002A8).l
	move.b	(IPX_unk_0F18).l,(BRAM_unk_2002A5).l
	move.b	(IPX_unk_0F19).l,(BRAM_unk_2002A6).l
	move.b	(IPX_unk_0F21).l,(BRAM_unk_2002AC).l
	move.b	(IPX_TimeStones_Array).l,(BRAM_TimeStones_Array).l 
	bsr.w	IPX_loc_D1C

	move.w	#unk_file_8C,d0
	btst	#0,(IPX_unk_0F1F).l
	bne.s	IPX_loc_CD4
	move.w	#unk_file_88,d0

IPX_loc_CD4:
	bsr.w	IPX_loc_CE0
	bsr.w	IPX_loc_D10
	bra.w	IPX_loc_D1C
; -----------------------------------------------------------------------------

IPX_loc_CE0:
	move.w	d0,(IO_unk_A12010).l

IPX_loc_CE6:
	move.w	(IO_unk_A12020).l,d0
	beq.s	IPX_loc_CE6
	cmp.w	(IO_unk_A12020).l,d0
	bne.s	IPX_loc_CE6

	move.w	#0,(IO_unk_A12010).l

IPX_loc_CFE:
	move.w	(IO_unk_A12020).l,d0
	bne.s	IPX_loc_CFE
	move.w	(IO_unk_A12020).l,d0
	bne.s	IPX_loc_CFE
	rts
; -----------------------------------------------------------------------------

IPX_loc_D10:
	btst	#0,(IO_unk_A12003).l
	beq.s	IPX_loc_D10
	rts
; -----------------------------------------------------------------------------

IPX_loc_D30:
	move.w	sr,(IPX_unk_0DA6).l
	move.w	#$2700,sr
	move.w	#$0100,(Z80_Bus_Request).l

IPX_loc_D42:
	btst	#0,(Z80_Bus_Request).l
	bne.s	IPX_loc_D42
	rts
; -----------------------------------------------------------------------------

IPX_loc_D4E:
	move.w	#0,(Z80_Bus_Request).l
	move.w	(IPX_unk_0DA6).l,sr
	rts
; -----------------------------------------------------------------------------

IPX_loc_D5E:
	bset	#0,(IPX_unk_0F00).l
	move.w	#$2500,sr

IPX_loc_D6A:
	btst	#0,(IPX_unk_0F00).l
	bne.s	IPX_loc_D6A
	rts
; -----------------------------------------------------------------------------

IPX_RandomTimezone_Warp:
	move.w	(IPX_FramesCounter_Level).l,d1
	lsr.w	#4,d1
	andi.w	#3,d1

	cmpi.b	#1,(IPX_PreviousTimeZone).l
	blt.s	IPX_RandomTimezone_Warp_FromPast
	bgt.w	IPX_RandomTimezone_Warp_FromFuture

;IPX_RandomTimezone_Warp_FromPresent:
	btst	#1,(IPX_CurrentTimeZone).l
	beq.s	IPX_RandomTimezone_Warp_FromPresent_ToPast

	bset	#1,d1

IPX_RandomTimezone_Warp_ToFuture:
	move.b	(a0,d1.w),d0
	bra.w	IPX_RandomTimezone_Future
; -----------------------------------------------------------------------------

IPX_RandomTimezone_Warp_FromPresent_ToPast:
	move.b	1(a0),d0
	rts
; -----------------------------------------------------------------------------

IPX_RandomTimezone_Warp_FromPast:
	bsr.w	IPX_TestMachineFlag_Warp
	btst	#1,d1
	bne.s	IPX_RandomTimezone_Warp_ToFuture

;IPX_RandomTimezone_Warp_ToPresent:
	move.b	0(a0),d0
	rts
; -----------------------------------------------------------------------------

	dephase
	if * > $16F634A
		fatal "IPX___.MMD RAM variables in $0EFA-$0EFF are erased! $\{*} > $16F634A"
	else
		message "IPX___.MMD RAM variables in $0EFA-$0EFF: $\{*} <= $16F634A"
	endif
	org	$16F634A
	phase	$16F634A-$130

IPX_RAM_0EFA:	dc.w	0
IPX_RAM_0EFC:	dc.b	0
		dc.b	0 ; Free byte
IPX_RAM_0EFE:	dc.b	0
IPX_RAM_0EFF:	dc.b	0

	dephase

; ===========================================================================
; end of IPX___.MMD file
IPX_End:
	if * > $16F6350 ; Maximum code size allowed for this file
		fatal "IPX___.MMD maximum code size reached! $\{*} > $16F6350"
	endif
