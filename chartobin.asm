;Description:	This program takes user input, if it is a character then it prints
;				the ASCII code in binary, and prints uppercase & lowercase versions.
;				It will repeat until the user decides to quit.

;Formatting is messed up after upload.

			org 100h
			
section		.data
	prompt	db	"Input an alphabetic character: $"
	err		db	10, 13, "That is not an alphabetic character.$"
	rpt		db	10, 13, "Do you want to try again?$"
	binary	db	10, 13, "Binary: $"
	up		db	10, 13, "Uppercase: $"
	low		db	10, 13, "Lowercase: $"
	crlf	db	10, 13, '$'
	input	db	' '

section		.text

;print the prompt; take and validate input
in:
	mov		ah, 9		;display string fcn
	mov		dx, prompt	;fcn 09h reads from dx
	int		21h			;display it
	mov		ah, 1		;read char fcn
	int		21h			;read input
	mov		[input], al	;save input for later (we will destroy it here)
	and 	al, 11011111b	;mask will clear bit 5, only need to validate uppercase char
	sub		al, 'A'			;simplifies compare (0-25 is valid now)
	cmp		al, 26		;if 0-25, must be character
	jge		error		;character is not alphabetical, print error
	cmp		al, 0		;if negative, not character
	jl		error		;will print error msg, then return to loop
	call	BIN			;to print binary
	call	UPPER		;to print uppercase
	call	LOWER		;to print lowercase
	
cont:
	mov		dx, rpt		;prompt to be printed
	mov		ah, 9		;display string fcn
	int		21h			;display it
	
	mov		ah, 1		;read input to al
	int		21h			;read it
	and		al, 0b11011111	;mask out possibility of 'y'
	cmp		al, 'Y'		;input we are checking for
	mov		dx, crlf	;cr/lf to make results readable if repeat
	int		21h			;print newline
	je		in			;user wants to continue
	jne		exit		;otherwise, user wants to exit

error:
	mov		dx, err		;error msg for invalid input
	mov		ah, 09h		;display string fcn
	int		21h			;display it
	jmp 	cont		;return to check continuation

UPPER:		;will print label, convert and print uppercase
	mov		ah, 9		;display string fcn
	mov		dx, up		;will display label
	int		21h			;display it
	mov		dl, [input]	;the char to be displayed
	and		dl, 0b11011111	;masking to obtain uppercase
	mov		ah, 2		;display char fcn
	int		21h			;display it
	ret					;return to main body (pops stack)
		
LOWER:		;will print label, convert and print lowercase
	mov		ah, 9		;display string fcn
	mov		dx, low		;lowercase label
	int		21h			;display the label
	mov		ah, 2		;display char fcn
	mov		dl,  [input];modified input to display
	or		dl, 0b00100000	;or bit 5 to make lowercase
	int		21h			;display it
	ret					;returns to main body (pops stack)

BIN:		;will rol through input to print out binary
	mov		dx, binary	;print binary label
	mov		ah, 9		;display string fcn
	int		21h			;display it
	mov		cx, 8		;initializing loop count for 8 bits
	mov 	ah,	2		;display char fcn, will save 2 bytes outside of loop
	mov		bl, [input]	;preparing to rol through input

	top:
		rol	 bl, 1		;will shift MSB into CF
		jc	 one		;jump if carry flag set (to 1) to 'one' case
		mov	 dl, '0'	;if not 1, we will print '0'
		jmp	 print		;will now print (either value)
	one:
		mov	 dl, '1'	;to print '1'
	print:	
		int	 21h		;print it	
		loop top		;continue rol
	
	ret					;returns to main body (pops stack)

exit:
	mov ah, 4Ch			;DOS exit fcn
	mov al, 0			;exit condition normal
	int 21h				;exiting
