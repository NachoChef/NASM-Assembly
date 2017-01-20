	;jkj-lab2.asm
		org 100h
		
section		.data
	prompt 	db	"?"
	crlf		db	13, 10, '$'
	input		db	?
	sum			db	?

section		.text
;display ?, take input
	mov 	ah, 9		;display string fcn
	mov		dx, prompt	;int 21h fcn 9 reads from dx
	int		21h			;display prompt
	
	mov 	ah, 1		;read char fcn
	int 	21h			;read it (stored to al)

;separate numbers
	mov 	ax, al		;prepare input for operations
	mov		ax, input	;preparing for division, dividend pulled from ax
	mov		bx, 10		;setting divisor to 10
	div		bx			;dividing input by 10 to obtain both #s
	
;add numbers
	mov		ax, al		;quotient of div is stored in al, this is left #
	mov		bx, ah		;remainder (# in right position when div by 10) is stored in ah
	add		ax, bx		;summation of left/right #s
	mov		sum, ax		;store summation in sum

;move to next line
	mov 	ah, 9		;display char fcn
	mov 	dx, crlf	;cr/lf pair
	int 	21h			;execute fcn 9

;display sum
	mov		ah, 9		;display char fcn
	mov 	dx, sum		;fcn 9 pulls from dx
	int		21h			;display it

;exit to DOS
	mov ah, 4Ch			;DOS exit fcn
	mov al, 0			;exit condition normal
	int 21h				;exiting
