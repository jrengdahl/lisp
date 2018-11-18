;node types
constype:	equ	0
numtype:	equ	8
rattype:	equ	16
flttype:	equ	24
strtype:	equ	32
arraytype: equ	40
chartype:	equ	48
primtype: equ	56
sfuntype:	equ	64
symtype:	equ	72

;list node structure

nodetype:		equ	0
nodeflags:	equ	2
car: 		equ	4
cdr:			equ	8

;symbol node structure

sym_value:	equ	4
sym_more:	equ	8

;second node of symbol

sym_function: equ 0
sym_plist: equ 4
sym_name: equ 8

;number node structure

numerator:	equ	4
denominator:	equ	8

;string node structure

str_length:	equ	2
str_data:	equ	4
str_more:	equ	8

;character node structure

char_data equ 4
char_attr equ 8


;primitive node structure

prim_addr equ 4
prim_name equ 8


;node block definitions
nodesize:		equ		12
nodeblocksize	equ		16384
nextnodeblock:	equ		0
nodeblockstuff: equ		4
nodesperblock:	equ		16380/nodesize

