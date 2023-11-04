;===========================================================================
; reZet80 - Z80-based retrocomputing and retrogaming
; (c) copyright 2016-2023 Adrian H. Hilgarth (all rights reserved)
; 8279 driver (_pkdi.asm) [last modified: 2023-01-11]
; indentation setting: tab size = 8
;===========================================================================
; after hardware reset 8279 Programmable Keyboard/Display Interface sets
; mode to 16 chars left entry and encoded keyboard with 2-key lockout
;---------------------------------------------------------------------------
; init 8279 [uses A]
_8279_init:	ld a, c1h		; clear 8279 display RAM and FIFO
		out (_8279SC), a
_8279_ready:	in a, (_8279SC)		; wait for 8279 to finish
		rlca			; if bit 7 of status byte set
		jr c, _8279_ready	; display is unavailable
		ld a, 34h		; init clock prescaler to 20
		out (_8279SC), a
		ret
;---------------------------------------------------------------------------
; write to display RAM with auto increment [uses A]
_8279_write:	ld a, 90h
		or e			; adjust display position
		out (_8279SC), a
		ret
;===========================================================================
