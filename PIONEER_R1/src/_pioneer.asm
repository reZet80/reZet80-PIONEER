;===========================================================================
; reZet80 - Z80-based retrocomputing and retrogaming
; (c) copyright 2016-2023 Adrian H. Hilgarth (all rights reserved)
; reZet80 PIONEER (_pioneer.asm) [last modified: 2023-01-20]
; indentation setting: tab size = 8
;===========================================================================
; ROM:
_ROM_2K:	equ 0			;  2 KiB ROM (0000-07FF)
_ROM_4K:	equ 1			;  4 KiB ROM (0000-0FFF)
_ROM_6K:	equ 0			;  6 KiB ROM (0000-17FF)
_ROM_8K:	equ 0			;  8 KiB ROM (0000-1FFF)
_ROM_10K:	equ 0			; 10 KiB ROM (0000-27FF)
_ROM_12K:	equ 0			; 12 KiB ROM (0000-2FFF)
_ROM_14K:	equ 0			; 14 KiB ROM (0000-37FF)
; RAM:
_RAM_1K:	equ 1			; 1 KiB RAM (3C00-3FFF)
_RAM_2K:	equ 0			; 2 KiB RAM (3800-3FFF)
;---------------------------------------------------------------------------
; I/O ports:
_8279D:		equ 00h			; 8279 data read / write
_8279SC:	equ 01h			; 8279 status read / command write
;---------------------------------------------------------------------------
; memory:
if _RAM_1K
_keyb:		equ 3c00h		; active key block
_buffer:	equ 3c02h		; 14-digit buffer (3C02-3C0F)
endif
if _RAM_2K
_keyb:		equ 3800h		; active key block
_buffer:	equ 3802h		; 14-digit buffer (3802-380F)
endif
;---------------------------------------------------------------------------
; start of Z80 execution - maskable interrupts disabled by hardware reset
		di			; needed for soft reset
		im 1			; simple interrupt mode 1
		ld hl, 4000h		; top of RAM
		jr _init		; initialization
;---------------------------------------------------------------------------
		ds 08h, 0ffh		; rst 08
		ds 08h, 0ffh		; rst 10
		ds 08h, 0ffh		; rst 18
		ds 08h, 0ffh		; rst 20
;---------------------------------------------------------------------------
; rst 28 - table lookup [uses A (input)(output), HL (input)]
_28H:		add a, l
		jr nc, _28H_
		inc h			; crossed 256-byte boundary
_28H_:		ld l, a
		ld a, (hl)
		inc hl
		ret
;---------------------------------------------------------------------------
; rst 30 - load table value [uses A (input), HL (input)(output)]
_30H:		add a, a		; * 2
		rst 28h
		ld h, (hl)
		ld l, a
		call 0306h		; _unpack
		ret
;---------------------------------------------------------------------------
_isr:		reti			; ISR starts at 0038
		ds 04h, 0ffh		; fill up
;---------------------------------------------------------------------------
; display char [uses A (input), HL (pointer to 7-segment table)]
_char:		ld hl, _7segdat
		rst 28h
		out (_8279D), a
		ret
;---------------------------------------------------------------------------
; clear display [uses A, B, E]
_cls:		ld e, 00h		; leftmost display position
		call _8279_write
		ld b, 10h		; 16 chars
_cls_:		ld a, 24h		; blank
		call _char
		djnz _cls_
		ret
;---------------------------------------------------------------------------
; wait for key press [uses A (output), B, I]
_key:		ld a, i
		cp ffh			; any key pressed ???
		jr z, _key
		jr _key0
;---------------------------------------------------------------------------
_init:		ld sp, hl		; stack at top of RAM
		ld a, 0ffh
		ld i, a			; init i
		call _8279_init		; init PKDI
		jr 00e1h		; _hh start game immediately
;---------------------------------------------------------------------------
; NMISR starts at 0066 [preserves A, uses I]
_nmi:		push af			; save A
		in a, (_8279SC)		; read PKDI status byte
		and 0fh			; bits 0-3
		jr z, _nmir		; no keys in FIFO
		ld a, 40h		; prepare 8279 to read FIFO
		out (_8279SC), a
		in a, (_8279D)		; read key from FIFO
		and 3fh			; bits 0-5
		ld i, a			; I holds pressed key
_nmir:		pop af			; restore A
		retn
;---------------------------------------------------------------------------
; key codes: 29h-2fh unused
; '_' (28)
; ' ' (24)  '.' (25)  ',' (26)  ''' (27)
; 'W' (20)  'X' (21)  'Y' (22)  'Z' (23)
;---------------------------------------
; 'S' (1C)  'T' (1D)  'U' (1E)  'V' (1F)
; 'O' (18)  'P' (19)  'Q' (1A)  'R' (1B)
; 'K' (14)  'L' (15)  'M' (16)  'N' (17)
; 'G' (10)  'H' (11)  'I' (12)  'J' (13)
;---------------------------------------
; 'C' (0C)  'D' (0D)  'E' (0E)  'F' (0F)  BACK  (13|83)
; '8' (08)  '9' (09)  'A' (0A)  'B' (0B)  ESC   (12|82)
; '4' (04)  '5' (05)  '6' (06)  '7' (07)  SHIFT (11|81)
; '0' (00)  '1' (01)  '2' (02)  '3' (03)  ENTER (10|80)
;------------------------------------------------------
_key0:		cp 10h
		jr c, _key1		; 00-0F
		add 70h			; 10-13 -> 80-83
		jr _key3
_key1:		push af			; save key
		ld a, (_keyb)		; take key block into account
		ld b, a			; count
		and a
		pop af			; restore key
		jr z, _key3		; default key block
_key2:		add a, 10h		; next key block [G-V][W-_]
		djnz _key2
_key3:		ld b, a
		ld a, ffh
		ld i, a			; reset i
		ld a, b
		ret
;---------------------------------------------------------------------------
; show prompt [uses A]
_prompt:	ld a, (_keyb)
		rlca
		rlca
		rlca
		rlca
		call _char
		ld a, 28h		; '_'
		jr _char
;---------------------------------------------------------------------------
include "_pkdi.asm"
include "_7segdat.asm"
if _RAM_1K
include "_hhdat1.asm"
endif
if _RAM_2K
include "_hhdat2.asm"
endif
;---------------------------------------------------------------------------
; fill up
if _ROM_2K
		ds 0800h-$, 0ffh
endif
if _ROM_4K
		ds 1000h-$, 0ffh
endif
if _ROM_6K
		ds 1800h-$, 0ffh
endif
if _ROM_8K
		ds 2000h-$, 0ffh
endif
if _ROM_10K
		ds 2800h-$, 0ffh
endif
if _ROM_12K
		ds 3000h-$, 0ffh
endif
if _ROM_14K
		ds 3800h-$, 0ffh
endif
;===========================================================================
