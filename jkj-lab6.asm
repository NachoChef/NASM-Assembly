
;	Name: Justin Jones
;	Date: 11/18/2016
;	Description: This program will take 2 string inputs, calculate word and length
;				counts, then display the inputs along with respective data. The program
;				utilizes stack activation records in order to take
;				user defined variables in generalized, reusable procedures.

			org 	100h
section .data
	in1		dw	"Please enter the first string: $"
	in2 	dw	"Please enter the second string: $"
	length1	dw	"The first string has a length of $"
	length2	dw	"The second string has a length of $"
	wrdlab1	dw	"The first string has a word count of $"
	wrdlab2	dw	"The second string has a word count of $"
	strlab1	dw	"The first string is: $"
	strlab2	dw	"The second string is: $"
	crlf	db	13, 10, '$'
	len1	db	0
	len2	db	0
	word1	db	0
	word2	db	0

section .bss	
	string1	resb	100
	string2	resb	100

section	.text
;begin main

;input first string
	mov		dx, in1			;input message for string 1
	mov		ah, 9			;display string fcn
	int		21h				;display it
	push	string1			;variable to store input in
	call	INSTRING		;read into variable
	
;input second string
	mov		dx, in2			;input message for string 2
	mov		ah, 9			;print string fcn
	int		21h				;display it
	push	string2			;string array to print
	call	INSTRING		;print it
	
	mov		dx, crlf		;CRLF
	int		21h				;print it

;calculate length of string1
	push	string1			;string to calc length of pushed first
	call	LENGTH			;calculate and store length
	mov		[len1], ax		;save length in corresponding variable

	mov		ah, 9			;print string fcn
	mov		dx, length1		;len label to print
	int		21h				;print msg
	
	push	word [len1]		;base 10 length to print
	call	NUMOUT			;print it
	
	mov		dx, crlf		;CR/LF
	int		21h				;print it
	
;calculate length of string2
	push	string2			;string fcn to calc length of pushed first
	call	LENGTH			;len label to print
	mov		[len2], ax		;print msg
	
	mov		ah, 9			;print string fcn
	mov		dx, length2		;len label to print
	int		21h
	
	push	word [len2]		;push # to print
	call 	NUMOUT			;print it
	
	mov		dx, crlf		;CR/LF
	int		21h				;print it
	
;word count of string1	
	push	string1			;string to calculate word count of
	call 	WCOUNT			;count words, return in ax
	mov		[word1], ax		;save to variable
	
	mov		ah, 9
	mov		dx, wrdlab1		;label for s1 word count
	int		21h				;print it
	
	push	word [word1]	;int to print
	call	NUMOUT			;print it

	mov		dx, crlf		;CR/LF
	int		21h				;print it

;word count of string2
	push	string2			;string to calculate word count of
	call	WCOUNT			;count words, return ax
	mov		[word2], ax		;save to variable
		
	mov		ah, 9			;print string fcn
	mov		dx, wrdlab2		;word label
	int		21h				;print it

	push	word [word2]	;number to print
	call	NUMOUT			;print it
		
	mov		dx, crlf		;CR/LF
	int		21h				;print it
	int		21h				;print it (again)

;print string 1
	mov		ah, 9			;print string fcn
	mov		dx, strlab1		;string label
	int		21h				;print it
	
	push	string1			;string to print (1)
	call	PRINTLN			;print it
	
;print string 2
	mov		ah, 9			;print string fcn
	mov		dx, strlab2		;string label
	int		21h				;print it
	
	push	word [len2]		;length of string
	push	string2			;string to print (2)
	call	PRINTLN			;print it

exit:mov	ax, 4C00h		;ah: exit fcn; al: normal exit code
	int		21h				;quit

;end main

;Begin procedures-------v

;takes string array address from stack and stores input into it,
;clears stack args upon completion
INSTRING:
	push	bp				;save bp
	push	ax				;save register
	mov		bp, sp			;copy sp
	mov		di, [bp+6]		;di = string
	cld                     ;process from left 
	mov     ah,1            ;input char fcn
	int     21h             ;read a char into AL
while1:	cmp al,0Dh      	;check for cr
	je      endwhile1	    ;if CR, exit
	cmp     al,08h          ;check for backspace 
	jne     else1           ;if not, save
	dec     di              ;if backspace, move index back
	jmp     read            ;read again without storing
else1:stosb                 ;store char in string
read:int     21h            ;read char into al again
	jmp     while1          ;continue loop until CR
endwhile1:
	mov		al, 0			;null terminating string
	stosb					;save
	pop		ax				;restore ax
	pop 	bp				;restore bp
	ret		2				;clear stack args and return
;end INSTRING proc

;will take string array address, calculate length, return it in ax
LENGTH:
	push	bp				;save old bp
	push	bx				;save bx
	push	cx				;save cx
	mov		bp, sp			;so we can access sp
	mov		di, [bp+8]		;address of string array var
	mov		cx, 100			;max 100 times (array length)
	mov		bx, 100			;cx initial value to calc length
	xor		ax, ax			;we search for 0 (null terminating)
	repne 	scasb			;repeat until we find 0
	inc 	cx				;inc 1 count after found - scasb dec even if found
	sub		bx, cx			;save into variable (preloaded with max length)
	mov		ax, bx			;length in ax now
	pop 	cx				;restore cx
	pop		bx				;restore bx
	pop		bp				;restore bp
	ret		2				;clear args	
;end LENGTH proc

;accepts string on stack, returns number of words in ax
WCOUNT:
	push	bp				;save old bp
	push	bx				;save bx
	mov		bp, sp			;copy sp into bp
	mov		bx, 1			;minimum 1
	mov		si, [bp+6]		;di is address of string array
	cld						;process left to right
	mov		ah, ' '			;search for space to count
topw:lodsb					;load char into al
	cmp		al, 0			;check for end of string
	je		done			;if end, done
	cmp		al, ah			;check if space
	jne		skip			;if not, repeat
	inc		bx				;otherwise, increment bx
skip:loop 	topw			;repeat for length of string
done:
	mov		ax, bx			;swap into ax
	pop		bx				;restore bx
	pop		bp				;restore bp
	ret		4				;return and clear stack arguments
;end WCOUNT

;accepts address of string on stack, prints to screen
PRINTLN:
	push	bp				;save bp
	push	ax				;save ax
	push	dx				;save dx
	mov		bp, sp			;copy sp into bp
	mov		si, [bp+8]		;di is address of string array
	mov     ah, 2           ;display char function
toppl:lodsb 				;load into al
	cmp		al, 0			;check if end
	je		endfor			;if end, done
	mov     dl,al           ;move it to dl
	int     21h             ;display character
	jmp	toppl           	;loop until done, left to right
endfor:
	mov		ah, 9			;print string fcn
	mov		dx, crlf		;CRLF
	int		21h				;print it
	pop		dx				;restore dx
	pop		ax				;restore ax
	pop		bp				;restore bp
	ret		2				;return and clear stack arguments
;end PRINTLN proc

;will accept base10 number, prints to screen
NUMOUT:
	push	bp				;save bp
	push	ax				;save ax
	push	bx				;save bx
	push	cx				;save cx
	push	dx				;save dx
	mov		bp, sp			;copy sp into bp
	mov		ax, [bp+12]		;load number into ax
	mov		bx, 10			;div by bx
	xor		cx, cx			;clear cx for count
while5:
	mov		dx, 0			;setup division - upper half 0
	div		bx				;begin division
	push 	dx				;save remainder to stack
	inc		cx				;increment counter for pop display
	cmp 	ax, 0			;check if quotient is 0
	jne 	while5			;cont if not 0
endwhile5:	
	mov		ah, 2			;print char fcn
loop5:
	pop 	dx				;pop to print
	or		dl, 30h			;clear top half of dx
	int		21h				;print it
	loop 	loop5			;loop times of cx
	pop		dx				;restore dx
	pop		cx				;restore cx
	pop		bx				;restore bx
	pop		ax				;restore ax
	pop		bp				;restore bp
	ret		2				;return to main prog, clear remaining stack
;end NUMOUT

