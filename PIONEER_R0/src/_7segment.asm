;===========================================================================
; reZet80 - Z80-based retrocomputing and retrogaming
; (c) copyright 2016-2021 Adrian H. Hilgarth (all rights reserved)
; 7-segment LED driver (_7segment.asm) [last modified: 2021-07-17]
; indentation setting: tab size = 8
;===========================================================================
; translates hexadecimal digit to 7-segment code
;  a : hexadecimal digit (input), 7-segment code to display (output)
; hl': pointer to 7-segment table
_7seg:		ld hl, _7seg_dat
		add a, l
		jr nc, _7seg_
		inc h			; crossed 256-byte boundary
_7seg_:		ld l, a
		ld a, (hl)
		ret
;---------------------------------------------------------------------------
; --A--		bit 0: A
; |   |		bit 1: B
; F   B		bit 2: C
; |   |		bit 3: D
; --G--		bit 4: E
; |   |		bit 5: F
; E   C		bit 6: G
; |   |		bit 7: DP
; --D-- DP
;---------------------------------------------------------------------------
_7seg_dat:
		db 3fh			; 0: 00111111b [  F E D C B A]
		db 06h			; 1: 00000110b [        C B  ]
		db 5bh			; 2: 01011011b [G   E D   B A]
		db 4fh			; 3: 01001111b [G     D C B A]
		db 66h			; 4: 01100110b [G F     C B  ]
		db 6dh			; 5: 01101101b [G F   D C   A]
		db 7dh			; 6: 01111101b [G F E D C   A]
		db 07h			; 7: 00000111b [        C B A]
		db 7fh			; 8: 01111111b [G F E D C B A]
		db 6fh			; 9: 01101111b [G F   D C B A]
		db 77h			; A: 01110111b [G F E   C B A]
		db 7ch			; b: 01111100b [G F E D C    ]
		db 39h			; C: 00111001b [  F E D     A]
		db 5eh			; d: 01011110b [G   E D C B  ]
		db 79h			; E: 01111001b [G F E D     A]
		db 71h			; F: 01110001b [G F E       A]
;===========================================================================
