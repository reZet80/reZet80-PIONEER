;===========================================================================
; reZet80 - Z80-based retrocomputing and retrogaming
; (c) copyright 2016-2021 Adrian H. Hilgarth (all rights reserved)
; reZet80 PIONEER (_pioneer.asm) [last modified: 2021-06-25]
; indentation setting: tab size = 8
;===========================================================================
; hardware configuration:		; default display is TIL311
_7SEG:		equ 0			; 7-segment LED display used instead
_74C923:	equ 1			; default keypad
_KEYPAD2:	equ 0			; alternative keypad
_RAM_1K:	equ 1			; 1 KiB main RAM
_RAM_2K:	equ 0			; 2 KiB main RAM
;---------------------------------------------------------------------------
; I/O ports:
_IO_KEYB2:	equ 50h			; alternative keypad
_IO_KEYB:	equ 60h			; keypad and alternative keypad
_IO_DISP:	equ 70h			; display
;---------------------------------------------------------------------------
; memory:				; 2 KiB ROM (0000-07FF)
if _RAM_1K				; 1 KiB RAM (3C00-3FFF)
_buffer:	equ 3c00h		; 6 hexadecimals (H1-H6) to display
endif					; 3C00-3C05
if _RAM_2K				; 2 KiB RAM (3800-3FFF)
_buffer:	equ 3800h		; 6 hexadecimals (H1-H6) to display
endif					; 3800-3805
;---------------------------------------------------------------------------
; start of Z80 execution - maskable interrupts disabled by hardware reset
		di			; needed for soft reset
		ld a, 0ffh
		ld i, a			; init i
		jp _init		; initialization
;---------------------------------------------------------------------------
		ds 08h, 0ffh		; rst 08h
		ds 08h, 0ffh		; rst 10h
		ds 08h, 0ffh		; rst 18h
		ds 08h, 0ffh		; rst 20h
		ds 08h, 0ffh		; rst 28h
		ds 08h, 0ffh		; rst 30h
;---------------------------------------------------------------------------
_isr:		reti			; ISR starts at 0038
		ds 2ch, 0ffh		; fill up
;---------------------------------------------------------------------------
if _74C923
; read key code from keypad encoder
; a': temp storage
; i : key code
_nmi:		ex af, af'		; NMISR starts at 0066
		in a, (_IO_KEYB)	; get key code
		and 1fh			; 5-bit key code
		ld i, a			; always overwrite last key
		ex af, af'
		retn
endif
if _KEYPAD2
_nmi:		retn			; NMISR starts at 0066
endif
;---------------------------------------------------------------------------
; convert hexadecimal number to 2 digits and save
;  a: hexadecimal number (input)
;  c: temp storage
; hl: ptr to display buffer [updated to point to next digit]
_todig:		ld c, a
		rrca
		rrca
		rrca
		rrca			; bits 4-7
		and 0fh
		ld (hl), a
		inc hl
		ld a, c
		and 0fh			; bits 0-3
		ld (hl), a
		inc hl
		ret
;---------------------------------------------------------------------------
_init:		im 1			; simple interrupt mode 1
		ld b, a			; b=ffh
		ld hl, 4000h		; determine location and amount of RAM
		ld d, h			; save for later use
		ld sp, hl		; stack at top of RAM
_init1:		dec hl			; start from 3FFF
		ld a, 55h		; 01010101b
		ld (hl), a
		cp (hl)
		jr nz, _init2
		cpl			; 10101010b = aah
		ld (hl), a
		cp (hl)
		jr z, _init1
_init2:		inc hl			; no more RAM found
		ld a, h
		call _todig		; display start of RAM (H1 & H2)
		xor a			; 00h (H3 & H4)
		call _todig
		ld a, d			; 40h
		sub h			; assume it's on 256-byte boundary
		rrca
		rrca			; in KiB
		and 0fh
		call _todig		; display amount of RAM (H5 & H6)
;---------------------------------------------------------------------------
include "_demon.asm"			; no jump/call so include first
if _7SEG
include "_7segment.asm"
endif
if _KEYPAD2
include "_keypad2.asm"
endif
;---------------------------------------------------------------------------
		ds 0800h-$, 0ffh	; fill up (2 KiB)
;===========================================================================
