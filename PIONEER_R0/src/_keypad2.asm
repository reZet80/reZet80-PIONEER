;===========================================================================
; reZet80 - Z80-based retrocomputing and retrogaming
; (c) copyright 2016-2021 Adrian H. Hilgarth (all rights reserved)
; alternative keypad driver (_keypad2.asm) [last modified: 2021-06-25]
; indentation setting: tab size = 8
;===========================================================================
; key codes:
; C (0ch)  D (0dh)  E (0eh)  F (0fh)  BACK  (13h)
; 8 (08h)  9 (09h)  A (0ah)  B (0bh)  ESC   (12h)
; 4 (04h)  5 (05h)  6 (06h)  7 (07h)  SHIFT (11h)
; 0 (00h)  1 (01h)  2 (02h)  3 (03h)  ENTER (10h)
;---------------------------------------------------------------------------
_key_io:	ld e, a			; e = active key row
		out (_IO_KEYB2), a
		in a, (_IO_KEYB)
		ld b, 04h
_key_check:	rrca			; any key pressed ?
		ret c
		inc d
		djnz _key_check
		ret
;---------------------------------------------------------------------------
_key_in:	exx
_key_scan:	ld d, 00h		; d = pressed key
		ld a, 01h		; row 1
		call _key_io
		jr c, _key_ok
		ld a, 02h		; row 2
		call _key_io
		jr c, _key_ok
		ld a, 04h		; row 3
		call _key_io
		jr c, _key_ok
		ld a, 08h		; row 4
		call _key_io
		jr c, _key_ok
		ld a, 10h		; row 5
		call _key_io
		jr nc, _key_scan	; wait for a key press
_key_ok:	ld c, d			; save pressed key
_key_rel:	ld a, e			; load particular key row
		call _key_io
		jr c, _key_rel		; wait as long as the key is pressed
		ld a, c			; returns 00h-13h
		exx
		ret			; all extra keys are back up
;===========================================================================
