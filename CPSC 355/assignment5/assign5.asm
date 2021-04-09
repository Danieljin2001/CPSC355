//Name: Daniel Jin
//UCID: 30107081
//Assignment 5, gets size of array through command-line and then generates a random NxN array. The numbers in the columns can be sorted
define(xSize, x19)		//defines x19 as xSize
define(size, w19)		//defines w19 as size
define(xSortC, x20)		//defines xSortC as x20
define(sortC, w20)		//defines sortC as w20

		.data
random:		.string	"%d\t"					//used to print elements
newLine:	.string	"\n"					//used to make new line
prompt: 	.string "Enter a column number: "		//ask column to be sorted
scan:		.string "%d"					//used to scan column number
prompt2:	.string	"\nTable sorted by column %d:\n"	//used to display which column was sorted
quit:		.string "Enter in 111 to quit\n"		//used to inform the user on how to quit

pn:		.string "assign5.log"				//this is the log file destination
mode:		.string "a+"					//mode append used for fopen
userIn:		.string "User changed column: %d\n"		//used to write into log file what column was changed
printQuit:	.string "\nUser inputted 111 and quit the program!\n"	//used to write into the logfile that the user has force quit the program

n:	.word 0
	
	.text
	.balign 4
	.global main
//array for sorting least to greatest
sort_count = 10		//max size is 10 elements
sort_size = 10 * 4	//10 elements * 4 bytes



//array for NxN
array_count = 10			//max count of the array size (from 0 to 10)
array_size = 10 * 10 * 4		//array_size = 10 cols * 10 rows * 4 bytes

array_s = 16				//address of NxN array, 16 because it counts for x29 and x30
sort_s = array_s + array_size		//address of 1D array used for sorting (NxN address + NxN size)

var_size = array_size + sort_size	//used to allocate for both arrays
alloc = -(16 + var_size) & -16		//make allocation divisible by 16
dealloc = -alloc			//dealloc is negation of alloc

fp	.req	x29			//fp = x29
lr	.req	x30			//lr = x30

main:	stp	fp, lr, [sp, alloc]!	
	mov	fp, sp

	mov	xSize, x1			//mov x1 into xSize (used for command line)
	mov	sortC, 1			//mov 1 into sortC (used to get the second argument in command line)
	ldr	x0, [xSize, sortC, sxtw 3]	//load the second argument into x0 as a string
	bl	atoi				//change the string into integer by calling C function
	mov	xSize, x0			//xSize is size
	SXTW	xSize, size			//change it into w register	

	add	x0, fp, array_s			//first arg is address of array
	mov	w1, size			//second arg. is size
	bl	initialize			//go to subroutine initialize

	add	x0, fp, array_s			//first arg is address of array
	mov	w1, size			//second arg is size
	bl	display				//goto subroutine display
	
	add	x0, fp, array_s			//first arg is address of NxN
	mov	w1, 99				//second arg is 99 to indicate to the subroutine that its first time making the table
	mov	w2, size			//third arg is size of array		
	bl	logFile				//go to function logFile
	
	adrp	x0, quit		
	add	x0, x0, :lo12:quit
	bl	printf				//telling user how to quit by using C function printf

ask:	adrp	x0, prompt			//asking to input a column to sort
	add	x0, x0, :lo12:prompt
	bl	printf				//uses C function printf
	
	adrp	x0, scan			
	add	x0, x0, :lo12:scan
	adr	x1, n
	bl	scanf				//scanning the input by using C function scanf
	
	adr	x1, n				
	ldr	xSortC, [x1]			//load the scanned value into xSortC
	mov	x1, xSortC			//xSortC is the column to sort
	SXTW	xSortC, sortC			//change to w register
	
	add	x0, fp, array_s			//first arg is address of array 
	mov	w1, sortC			//second arg is column to sort
	mov	w2, size			//third arg is size of array
	bl	logFile				//go to function logfile

	cmp	sortC, 111			//compare input with 111 to see if user force quit 
	b.eq	exit				//if equal go to exit
	
	mov	w1, sortC			//first arg is column that was choses
	adrp	x0, prompt2
	add	x0, x0, :lo12:prompt2
	bl	printf				//telling user what column was sorted while using C function printf

	add	x0, fp, array_s			//first arg is address of array
	add	x1, fp, sort_s			//seconf arg is address of 1D array
	mov	w2, size			//third arg is size
	mov	w3, sortC			//fourth arg is column chosen
	bl	sort				//go to function sort

	add	x0, fp, array_s			//first arg is address of array
	mov	w1, size			//second arg is size			
	bl	display				//goto display function
	

	b	ask				//if input is 111 then exit else keep asking
	

exit:	mov	w0, 0				//mov w0 to equal 0
	ldp	fp, lr, [sp], dealloc		//deallocate memory
	ret					

//this is to initiate the array with random numbers (param1, param2)
//param1 is the pointer to the NxN array
//param2 is the size of N
initialize:	stp	fp, lr, [sp, -16]!
		mov	fp, sp
	
		mov	w21, w1		//w21 = size	
		mov	w22, 0		//i = 0
		mov	w23, 0		//j = 0
		mov	x24, x0		//x24 = address + fp
		mov	x25, 10		//used to do modulus (%10)
		
		mov	x0, xzr		//set x0 as 0 for the next following function
		bl	time		//use C funtion time
		bl	srand		//use C function srand
		
		b	test1		//go to test1
	
loop:		bl	rand		//use C function rand
		udiv	x28, x0, x25	//quotient = rand/10
		msub	x28, x28, x25, x0	//result = quotient-(rand*10) (making the randon number from 0 to 9)

		mul	w27, w22, w21	//offset = i * N
		add	w27, w27, w23	//offset = (i * N) + j
		lsl	w27, w27, 2	//offset = ((i * N) + j)*4

		str	w28, [x24, w27, SXTW]	//store the rand number into array[i][j]
		
		add	w23, w23, 1	//j++
		b	test1		//go to test1


test2:		cmp	w23, w21	//compare j and size
		b.lt 	loop		//if less go to loop
			

		add	w22, w22, 1	//i++
		mov	w23, 0		//set j to 0 again

test1:		cmp	w22, w21	//compare size and i
		b.lt	test2		//if less go to test2
				
		mov	w0, 0		//exit
		ldp	fp, lr, [sp], 16
		ret	

//this subroutine is used to display to the user what is in the NxN array (param1, param2)
//param1 is the address of the NxN array
//parma2 is the size of the array
display:	stp 	fp, lr, [sp, -16]!
		mov	fp, sp
		
		mov	w21, w1		//w21 = size
		mov	w22, 0		//i = 0
		mov	w23, 0		//j = 0
		mov	x24, x0		//x24 = address

		b	test3		//goto test3

loop2:		mul	w27, w22, w21		//offset = N * i
		add	w27, w27, w23		//offset = (N * i) + j
		lsl	w27, w27, 2		//offset = ((N * i) + j) * 4
		
		ldr	w1, [x24, w27, SXTW]	//load the array[i][j] into w1
		
		adrp	x0, random		
		add	x0, x0, :lo12:random
		bl	printf			//print out the random number using printF function from C
		
		add	w23, w23, 1		//j++
		b	test3			//goto test3

test4:		cmp	w23, w21		//compare j and size
		b.lt	loop2			//if less go to loop
	
		adrp	x0, newLine		
		add	x0, x0, :lo12:newLine
		bl	printf			//print \n using printf function

		add	w22, w22, 1		//i++
		mov	w23, 0			//reset j

test3:		cmp	w22, w21		//compare i with size
		b.lt	test4			//if less go to test4

		mov	w0, 0			//exit
		ldp	fp, lr, [sp], 16
		ret
//this subroutine sorts out the given column (param1, param2, param3, param4)
//param1 is the pointer to the NxN arrray
//param2 is the pointer to the 1D array to sort
//param3 is the size of the table
//param4 is the chosen column to sort
sort:	stp	fp, lr, [sp, -16]!
	mov	fp, sp
	
	mov	w21, w2		//w21 is size
	mov	w22, 0		//i = 0
	mov	w23, w3		//w23 = chosen column
	mov	x24, x0		//x24 = address of table
	mov	x25, x1		//x25 = address of 1D array
	
	//start of populating 1D array with given column
	b	test5
	
loop3:	mul	w27, w22, w21			//offset = i * n
	add	w27, w27, w23			//offset = i * n + chosen
	lsl	w27, w27, 2			//offset = (i * n + chosen)*4
	
	ldr	w26, [x24, w27, SXTW]		//loading element into w26
	str	w26, [x25, w22, SXTW 2]		//storing element value into the 1D array
	
	add	w22, w22, 1			//i++

test5:	cmp	w22, w21			//compare i with size
	b.lt	loop3				//if less go to loop

	//start of the bubble sort	
	mov	w22, 0				//reset i				
	mov	w26, 0				//j = 0
	sub	w21, w21, 1			//k = n-1

	b	test6				//goto test6

loop4:	ldr	w11, [x25, w26, SXTW 2]		//load  array[j] to w11
	add	w27, w26, 1			
	ldr	w12, [x25, w27, SXTW 2]		//load array[j+1]

	cmp	w11, w12			//compare the two elements
	b.gt	swap				//if w11 is greater than w12 than swap
	b	noswap				//if not then dont swap
swap:	str	w11, [x25, w27, SXTW 2]		//store w11 where w12 was
	str	w12, [x25, w26, SXTW 2]		//store w12 where w11 was

noswap:	add	w26, w26, 1			//j++
	b	test6				//goto test6

test7:	sub	w28, w21, w22			//w28 = k - i
	cmp	w26, w28			//compare j and w28
	b.lt	loop4				//if less go to loop
	add	w22, w22, 1			//i++
	mov	w26, 0				//reset j

test6:	cmp	w22, w21			//compare i and k
	b.lt	test7				//if less go to test7
	//start of changing up the elements to what it was sorted into
	mov	w22, 0				//i = 0
	add	w21, w21, 1			//revert back the size to normal
	
	b	test8				//goto test8
		
loop5:	ldr	w28, [x25, w22, SXTW 2]		//load element into w28
	
	mul	w27, w22, w21			//offset = n * i
	add	w27, w27, w23			//offset = n * i + chosen column
	lsl	w27, w27, 2			//offset = (n*i+chosen)*4
	str	w28, [x24, w27, SXTW]		//store w28 into the array
	
	add	w22, w22, 1			//i++

test8:	cmp	w22, w21			//compare i and size
	b.lt	loop5				//if less go to loop

	mov	w0, 0				//exit
	ldp	fp, lr, [sp], 16
	ret	


//this subroutine prints into the logfile of what is being inputted into the system and also the table that is being generated (param1, param2, param3)
//param1 is the address of the NxN table
//param2 is the inputted value that the user inputs (999 if its the initial table generated)
//param3 is the size of NxN table
logFile:	stp	fp, lr, [sp, -16]!
		mov	fp, sp
		
		mov	w23, 0			//i = 0
		mov	w24, 0			//j = 0
		mov	w25, w2			//w25 is size of array
		mov	x26, x0			//x26 is address of array
		mov	w27, w1			//w27 is inputted value
				
	
		adrp	x0, pn			//first arg is assign5.log
		add	x0, x0, :lo12:pn	
		adrp	x1, mode		//second arg is mode a+
		add	x1, x1, :lo12:mode
		bl	fopen			//use function fopen from C

		mov	x28, x0			//x28 is file pointer
		

		cmp	w27, 99			//compare input to see if its 99
		b.eq	finish			//if eqal the ngo to finish
	
		b	test9			//goto test9

loop6:		mul	w22, w25, w23		//offset = i * n
		add	w22, w22, w24		//offset = i * n + j
		lsl	w22, w22, 2		//offset = (i * n + j) * 4
		
		mov	x0, x28			//first arg is file pointer
		adrp	x1, random		//second is random string
		add	x1, x1, :lo12:random		
		ldr	w2, [x26, w22, SXTW]	//third is element of the array
		bl	fprintf			//use function fprintffrom C
		
		add	w24, w24, 1		//j++
		b	test9			//goto test9

test10:		cmp	w24, w25		//compare size and j
		b.lt	loop6			//if less go to looop6
		
		mov	x0, x28			//first arg is file pointer
		adrp	x1, newLine		//second is \n as a string
		add	x1, x1, :lo12:newLine
		mov	w2, 0			//third is 0
		bl	fprintf			//use function fprintf
		
		add	w23, w23, 1		//i++
		mov	w24, 0			//reset j

test9:		cmp	w23, w25		//comapre i and size
		b.lt	test10			//if less go to test 10
		
		mov	x0, x28			//first arg is filepointer
		adrp	x1, newLine		//second is newline string
		add	x1, x1, :lo12:newLine
		mov	w2, 0			//third is 0
		bl	fprintf			//use function fprintf
		
		
		cmp	w27, 111		//compare if input is 111 
		b.eq	userQuit		//if equal then go to userquit
		
		mov	x0, x28			//first arg is filepointer
		adrp	x1, userIn		//second is userIn string
		add	x1, x1, :lo12:userIn
		mov	w2, w27			//third is input
		bl	fprintf			//use function fprintf
		
		b	finish			//go to finish
		

userQuit:	mov	x0, x28			//first arg is filepointer
		adrp	x1, printQuit		//second is printQuit as a string
		add	x1, x1, :lo12:printQuit	
		mov	w2, 0			//third is 0
		bl	fprintf			//use function fprintf
			
		//close the file here
finish:		mov	x0, x28			//first arg is filepointer
		bl	fclose			//use fclose
	
		mov	w0, 0			//exit
		ldp	fp, lr, [sp], 16
		ret
