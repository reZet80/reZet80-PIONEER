;===========================================================================
; reZet80 - Z80-based retrocomputing and retrogaming
; (c) copyright 2016-2021 Adrian H. Hilgarth (all rights reserved)
; reZet80 deMon = debug Monitor (_demon.asm) [last modified: 2021-07-17]
; indentation setting: tab size = 8
;===========================================================================
; main deMon execution loop
;  a: temp storage
;  b: examine/modify mode (00h), normal entry mode (ffh)
;  c: temp storage
; de: memory location to examine/modify
; hl: ptr to display buffer
;  i: key code
_loop:		ld hl, _buffer
_loop0:		call _dout
if _74C923
_loop1:		ld a, i
		cp 0ffh			; any key pressed ?
		jr z, _loop1
		ld c, a
		ld a, 0ffh
		ld i, a			; mark key as read
		ld a, c
endif
if _KEYPAD2
_loop1:		call _key_in
		ld c, a
endif
;---------------------------------------------------------------------------
; key codes:
; C (0ch)  D (0dh)  E (0eh)  F (0fh)  BACK  (13h)
; 8 (08h)  9 (09h)  A (0ah)  B (0bh)  ESC   (12h)
; 4 (04h)  5 (05h)  6 (06h)  7 (07h)  SHIFT (11h)
; 0 (00h)  1 (01h)  2 (02h)  3 (03h)  ENTER (10h)
		cp 10h			; 0-F ?
		jr z, _eval		; ENTER ?
		jr nc, _loop2		; > 10h ?
		ld a, l			; current buffer position
		cp 06h			; past H6 ?
		jr z, _loop1		; then ignore key
		ld (hl), c		; save key
		inc hl			; next display buffer position
		jr _loop0
_loop2:		cp 13h			; BACK ?
		jr nz, _loop4
		ld c, 00h		; H1
		ld a, b
		and a
		jr nz, _loop3		; not in examine/modify mode
		ld c, 04h		; H5
_loop3:		ld a, l
		cp c			; reached H1/H5 ?
		jr z, _loop1		; then ignore BACK key
		dec hl			; delete last digit
		jr _loop1
_loop4:		cp 12h			; ESC ?
		jr nz, _loop1
		ld a, b
		and a
		jr nz, _loop		; not in examine/modify mode
		dec b 			; back in normal entry mode
		jr _loop		; reset hl
;---------------------------------------------------------------------------
; available commands:
; '0XXXX':  jump to specified address
; '1ZYYXX': output byte to 16-bit I/O port
; 'EXXXX':  examine/modify memory from specified address on
_eval:		ld l, 00h		; H1
		ld a, b
		and a
		jr nz, _eval1		; not in examine/modify mode
		dec hl
		call _addr		; de holds address from H1 H2 H3 H4
		push de			; save de
		call _addr_		; e holds value from H5 H6
		ld a, e
		pop de			; restore de
		db 0ddh, 0bdh		; cp ixl (check for a change)
		jr z, _eval0		; value not changed
		ld (de), a		; write new value to memory
_eval0:		inc de			; next memory location
		jr _eval4
_eval1:		ld a, (hl)
		and a			; '0' ?
		jr nz, _eval2
		call _addr		; get address
		ex de, hl
		jp (hl)			; jump to address
_eval2:		dec a			; '1' ?
		jr nz, _eval3
		push bc			; save bc
		inc hl			; H2
		ld b, (hl)		; MSB of 16-bit I/O port ('Z')
		call _addr		; de holds value from H3 H4 H5 H6
		ld c, d			; LSB of 16-bit I/O port ('YY')
		ld a, e			; data to output ('XX')
		out (c), a		; 4-bit b ('Z') but has to be 8 bits
		pop bc			; restore bc
		jr _loop1		; should be '_loop' but would overwrite output to display
_eval3:		cp 0dh			; 'E' ?
		jr nz, _loop1
		call _addr		; get address
		inc b			; now in examine/modify mode
_eval4:		ld l, 00h		; H1
		ld a, d
		call _todig
		ld a, e
		call _todig
		ld a, (de)
		db 0ddh, 6fh		; ld ixl, a (put old value in ixl)
		call _todig
		dec hl
		dec hl			; H5
		jp _loop0
;---------------------------------------------------------------------------
; calculate address out of 4 digits
;  a: temp storage
; de: address
; hl: ptr to display buffer [updated to point to next digit]
_addr:		call _addr_
		ld d, a
_addr_:		inc hl
		ld a, (hl)
		rlca
		rlca
		rlca
		rlca
		inc hl
		or (hl)
		ld e, a
		ret
;---------------------------------------------------------------------------
; update 6 display digits
;  a : temp storage
;  b': digit to display (6 -> 1)
;  c': I/O address
; de': pointer to display buffer
_dout:		exx
		ld bc, 0670h		; b=H1 c=_IO_DISP
		ld de, _buffer
_dout_:		ld a, (de)
		inc de
if _7SEG
		call _7seg
endif
		out (c), a		; 16-bit I/O
		djnz _dout_
		exx
		ret
;===========================================================================
