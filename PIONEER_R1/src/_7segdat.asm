;===========================================================================
; reZet80 - Z80-based retrocomputing and retrogaming
; (c) copyright 2016-2022 Adrian H. Hilgarth (all rights reserved)
; 7-segment LED font data (_7segdat.asm) [last modified: 2022-12-27]
; indentation setting: tab size = 8
;===========================================================================
; --A--
; |   |
; F   B
; |   |
; --G--
; |   |
; E   C
; |   |
; --D--  P
;---------------------------------------------------------------------------
; bit 0: A
; bit 1: B
; bit 2: C
; bit 3: D
; bit 4: E
; bit 5: F
; bit 6: G
; bit 7: P (DP)
;---------------------------------------------------------------------------
; data for common cathode displays
; make sure table doesn't cross 256-byte boundary
_7segdat:
db 3fh	; 00h: '0': 00111111b [    F E D C B A]
db 06h	; 01h: '1': 00000110b [          C B  ]
db 5bh	; 02h: '2': 01011011b [  G   E D   B A]
db 4fh	; 03h: '3': 01001111b [  G     D C B A]
db 66h	; 04h: '4': 01100110b [  G F     C B  ]
db 6dh	; 05h: '5': 01101101b [  G F   D C   A]
db 7dh	; 06h: '6': 01111101b [  G F E D C   A]
db 07h	; 07h: '7': 00000111b [          C B A]
db 7fh	; 08h: '8': 01111111b [  G F E D C B A]
db 6fh	; 09h: '9': 01101111b [  G F   D C B A]
db 77h	; 0ah: 'A': 01110111b [  G F E   C B A]
db 7ch	; 0bh: 'B': 01111100b [  G F E D C    ]
db 39h	; 0ch: 'C': 00111001b [    F E D     A]
db 5eh	; 0dh: 'D': 01011110b [  G   E D C B  ]
db 79h	; 0eh: 'E': 01111001b [  G F E D     A]
db 71h	; 0fh: 'F': 01110001b [  G F E       A]
db 3dh	; 10h: 'G': 00111101b [    F E D C   A]
db 74h	; 11h: 'H': 01110100b [  G F E   C    ]
db 06h	; 12h: 'I': 00000110b [          C B  ]
db 1eh	; 13h: 'J': 00011110b [      E D C B  ]
db 75h	; 14h: 'K': 01110100b [  G F E   C   A]
db 38h	; 15h: 'L': 00111000b [    F E D      ]
db 55h	; 16h: 'M': 01010101b [  G   E   C   A]
db 54h	; 17h: 'N': 01010100b [  G   E   C    ]
db 5ch	; 18h: 'O': 01011100b [  G   E D C    ]
db 73h	; 19h: 'P': 01110011b [  G F E     B A]
db 67h	; 1ah: 'Q': 01100111b [  G F     C B A]
db 50h	; 1bh: 'R': 01010000b [  G   E        ]
db 6dh	; 1ch: 'S': 01101101b [  G F   D C   A]
db 78h	; 1dh: 'T': 01111000b [  G F E D      ]
db 3eh	; 1eh: 'U': 00111110b [    F E D C B  ]
db 1ch	; 1fh: 'V': 00011100b [      E D C    ]
db 1dh	; 20h: 'W': 00011101b [      E D C   A]
db 76h	; 21h: 'X': 01110110b [  G F E   C B  ]
db 6eh	; 22h: 'Y': 01101110b [  G F   D C B  ]
db 5bh	; 23h: 'Z': 01011011b [  G   E D   B A]
db 00h	; 24h: ' ': 00000000b [               ]
db 80h	; 25h: '.': 10000000b [P              ]
db 0ch	; 26h: ',': 00001100b [        D C    ]
db 20h	; 27h: ''': 01000000b [    F          ]
db 08h	; 28h: '_': 00001000b [        D      ]
;===========================================================================
