//Name: Daniel	Jin
//UCID: 30107081
//project part b, coded in assembly
define(xSize, x19)		//defines x19 as xSize
define(wSize, w19)		//defines w19 as wSize
define(xN, x21)			//defines x21 as xN
define(N, w21)			//defines w21 as N
define(xI, x22)			//defines x22 as xI
define(wI, w22)			//defines w22 as wI
define(xJ, x23)			//defines x23 as xJ
define(wJ, w23)			//defines w23 as wJ
define(frame, x24)		//defines x24 as frame
define(temp, x25)		//defines x25 as temp
define(wTemp, w25)		//defines w25 as wTemp
define(timer, x26)		//defines x26 as timer
define(amount, w26)		//defines w26 as amount
define(xGiven, x27)		//defines x27 as xGiven
define(offset, w27)		//defines w27 as offset
define(givenTime, x28)		//defines x28 as givenTime
define(value, w28)		//defines w28 as value

		.data
atSign:		.string	"@"		//used to display to user that time surprise was uncovered	
plusSign:	.string "+"		//used to display to user that reward was found
minusSign:	.string	"-"		//used to display to user that penalty was found
exSign:		.string	"!"		//used to display that bad surprise was found
starSign:	.string "X"		//used to display that element is covered
moneySign:	.string	"$"		//used to display to user that good surprise was found

newLine:	.string	"\n"						//used to make new line
move:		.string "Enter in your move (x, y) or '111 111' to quit: \n"			//used to ask user to enter in coordinates
scanMove:	.string  "%d %d"					//used to scan the coordinates inputted
reward:		.string	"\nUncovered a reward of %0.2f points\n"	//used to show user the reward earned
bang:		.string	"\nBang!! you lost %0.2f points\n"		//used to show the user how many points lost
oops:		.string "\noops already tried that area!\n"		//used to print to user when they try to uncover an already uncovered spot
dbScore:	.string	"\nGood surprise! Double your score\n"		//used to print to user when they find a good surprise
hfScore:	.string	"\nBad surprise! Half your score\n"		//used to print to user when they find a bad surprise
timeAdded:	.string	"\nTime surprise! Add 30 seconds to the clock\n"	//used to print to user when they find a timer surprise
showScore:	.string	"Score:	%0.2f\n"				//used to display to user their score
showTimer:	.string	"Timer: %d\n"					//used to display to user the timer
answer:		.string	"%d"						//used to scan the amount of top scores wanted to read
howMany:	.string	"How many scores would you like to see?(Enter 0 for none) \n"	//used to ask user if they would like to see top scores
line:		.string	"%s"						//used to scan the name inputted
gameOver:	.string	"Game Over!\n\n"				//used to display to user that game is over

pn:		.string "project.log"					//file name of logfile for highscores
name:		.string	"%s\t"						//used to write into file the name
printSec:	.string "Score: %0.2f\tTime: %d\n"			//used to write into file the time and score it took
append:		.string	"a+"						//mode append for file
read:		.string	"r"						//mode read for file
enter:		.string	"Enter in your name: "				//used to ask for user name

fMin:		.double	0r0.01			//used for the min of random number
fMax:		.double	0r14.99			//used to make the max of random number
fRAND_MAX:	.double	0r2147483647.00		//RAND_MAX as a double (0x7fffffff)
surprise:	.double	0r50.00			//used to indicate a bad or good surprise
time_surprise:	.double 0r60.00			//used to indicate a time surprise 
thirty:		.double	0r30.00			//used to check if the element has been uncovered or not
hund:		.double 0r100.00		//stored into element once reward or penalty is uncovered
twoHund:	.double	0r200.00		//stored into element once good or bad surprise is uncovered
twoFifty:	.double	0r250.00		//stored into element once time surprise is found
fZero:		.double	0r0.00			//used to check is an element is negative or not

//NxN array
array_count = 20		//max array count is 20
array_size = 20 * 20 * 8	//max rows * max cols * 8 bytes (double)
array_s = 16			//account for fp and lr 

//timer:
timer_size = 8			//8 bytes (long int)
timer_s = array_s + array_size	//address of timer, accounts for array

//score:
score_size = 8			//8 bytes (long int)
score_s = timer_s + timer_size	//address of score, accounts for timer address

//end: (end =1 means its done)
end_size = 4			//4 bytes (int)
end_s = score_s + score_size	//address of end, accounts for score address

alloc = -(16 +array_size + timer_size + score_size + end_size) & -16	//space to allocate for the addresses above

n:	.word 0				//used to scan %d
m:	.word 0				//used to scan %d
p:	.string ""			//used to scan %s
	
	.text
	.balign 4
	.global main

fp	.req	x29			//fp = x29
lr	.req	x30			//lr = x30

main:	stp	fp, lr, [sp, -16]!	//allocate memory
	mov	fp, sp			//fp = sp
	
	add	sp, sp, alloc		//allocate more memory

	mov	xSize, x1		//mov x1 into xSize (used for command line)
	mov	w20, 1			//mov 1 into w20 (used to get the second argument in command line)
	ldr	x0, [xSize, w20, sxtw 3]//load the second argument into x0 as a string
	bl	atoi			//change the string into integer by calling C function
	mov	xSize, x0		//xSize is size
	SXTW	xSize, wSize		//change it into w register	
	
	//reccord name and ask if user wants to see past scores
	mov	x0, fp			//first arg is fp
	mov	w1, 1			//second arg is 1 (1 = first occurence, so it asks for the name)
	mov	w2, wSize		//third is size of array (to calculate for timer)
	bl	logFile			//use logFile function

	//populates the array with random doubles (0.01 to 15.00)
	add	x0, fp, array_s		//first arg is address of array
	mov	w1, wSize		//second arg. is size
	bl	initialize		//go to subroutine initialize
	
	//score = 0.00 initially
	adr	temp, fZero		
	ldr	d25, [temp]		//d25 = 0.00
	str	d25, [fp, score_s]	//score = 0.00

	//start timer
	bl	time			//use time function from C
	str	x0, [fp, timer_s]	//time = starting time
	
	//display to user what the array looks like
	mov	x0, fp			//first arg is fp
	mov	w1, wSize		//second arg is size
	bl	display			//goto subroutine display	

	//end = 0 initially
	str	wzr, [fp, end_s]	//end = 0

	//asking when its first turn 
	adrp	x0, move			
	add	x0, x0, :lo12:move
	bl	printf			//ask to input coordinates
	adrp	x0, scanMove		
	add	x0, x0, :lo12:scanMove
	adr	x1, n			//x
	adr	x2, m			//y
	bl	scanf			//scan the inputted coordinates
	adr	x1, n			//x
	adr	x2, m			//y
	ldr	xI, [x1]		//xI is x
	ldr	xJ, [x2]		//xJ is y
	mov	x2, xI			//third arg is x
	mov	x3, xJ			//fourth arg is y
	mov	x0, fp			//first arg is fp
	mov	w1, wSize		//second arg is size
	bl	calculateScore		//use calculateScore function
	mov	x0, fp			//first arg is fp
	mov	w1, wSize		//second arg is size
	bl	display			//display to user the array again

	
	ldr	wTemp, [fp, end_s]	//temporarily let wTemp be value of end
	cmp	wTemp, 1		//if end == 1 
	b.eq	over			//then branch to over
	
//loop of asking user to input coordinates, and displaying the score, timer and array
ask:	adrp	x0, move		
	add	x0, x0, :lo12:move
	bl	printf			//ask user for coordinates
	adrp	x0, scanMove		
	add	x0, x0, :lo12:scanMove
	adr	x1, n			//x
	adr	x2, m			//y
	bl	scanf			//scan the move
	
	adr	x1, n			
	adr	x2, m
	ldr	xI, [x1]	//xI is x
	ldr	xJ, [x2]	//xJ is y
	
	//calculate the score
	mov	x2, xI		//third arg is x
	mov	x3, xJ		//fourth arg is y

	mov	x0, fp		//first arg is fp
	mov	w1, wSize	//second arg is size
	bl	calculateScore	//go to function

	//display the NxN
	mov	x0, fp		//first arg is fp
	mov	w1, wSize	//second is size
	bl	display		//go to function
	
	//check if all the elements are uncovered
	mov	x0, fp		//first arg is fp
	mov	w1, wSize	//sec is size
	bl	checkAll	//use fnction

	//check if score is less than or equal to 0
	ldr	d25, [fp, score_s]	//d25 = score
	fcmp	d25, 0.00		//compare score and 0
	b.le	change			//if <= then go to change
	b	check			//else go to check

//chnaging the end value to 1
change:	ldr	wTemp, [fp, end_s]	//wTemp = end
	mov	wTemp, 1		//wTemp = 1
	str	wTemp, [fp, end_s]	//end = wTemp
	
//checking if end is 1	
check:	ldr	wTemp, [fp, end_s]	//load end value into wTemp
	cmp	wTemp, 1		//if end is 1 then done, else ask again
	b.ne	ask			//go ask	
	
//if end == 1	
over:	adrp	x0, gameOver		
	add	x0, x0, :lo12:gameOver
	bl	printf			//print out to user Game over!
	ldr	timer, [fp, timer_s]	//timer = start timer
	mov	x0, xzr			//x0 = 0 for next following function
	bl	time			//use time
	sub	timer, x0, timer	//timer (counting up)= current - start
	mov	givenTime, 12			//givenTime = 12 
	mul	givenTime, givenTime, xSize	//giventime = 12 * size
	sub	timer, givenTime, timer	//timer (counting down) = giventime - timer(counting up)
	
	cmp	timer, 0		//compare timer with 0
	b.le	mkZero			//if <= then go to mkzero
	b	prints			//if not then go to prints
mkZero:	mov	timer, 0		//if timer <= 0, timer = 0 so its not negative
prints:	adrp	x0, showScore		
	add	x0, x0, :lo12:showScore
	ldr	d0, [fp, score_s]	//d0 = score
	bl	printf			//print the score
	
	adrp	x0, showTimer
	add	x0, x0, :lo12:showTimer
	mov	x1, timer		//x1 = timer
	bl	printf			//print the timer
	
	//use logFile to (second occurence) to ask user if they want to see score, and also logs in the score and time
	mov	x0, fp			//first arg is fp
	mov	w1, 0			//second arg is 0 (second occurence so it doenst ask for name)
	mov	w2, wSize		//third is size
	bl	logFile			//use logfile

	sub	sp, sp, alloc		//deallocate added memory

exit:	mov	w0, 0				//mov w0 to equal 0
	ldp	fp, lr, [sp], 16		//deallocate memory
	ret					

//this is to initiate the array with random numbers (param1, param2)
//param1 is the pointer to the NxN array
//param2 is the size of N
initialize:	stp	fp, lr, [sp, -16]!
		mov	fp, sp
	
		mov	N, w1		//N = size	
		mov	wI, 0		//i = 0
		mov	wJ, 0		//j = 0
		mov	frame, x0	//frame = address + fp
		
		adr	temp, fMax	
		ldr	d19, [temp]	//d19 is 14.99 used for making range of random number
		
		adr	temp, fMin	
		ldr	d20, [temp]	//d20 is 0.01 used for making range in random number

		adr	temp, fRAND_MAX
		ldr	d21, [temp]	//d21 is RAND_MAX in type double


		mov	x0, xzr		//set x0 as 0 for the next following function
		bl	time		//use C funtion time
		bl	srand		//use C function srand
				
//first populates the array with doubles 0.01 to 15.00
		b	test1		//go to test1
	
loop:		bl	rand		//use C function rand
		mov	givenTime, x0	//givenTime is random number in integer
		scvtf	d28, givenTime	//convert it to double
		fdiv	d22, d28, d21	//random = rand() / RAND_MAX
		fmul	d22, d22, d19	//random = (rand() / RAND_MAX) * 14.99
		fadd	d22, d22, d20	//random = ((rand() / RAND_MAX) * 14.99) + 0.01	(Range of random number is 0.01 to 15.00)	

		mul	offset, wI, N		//offset = i * N
		add	offset, offset, wJ	//offset = (i * N) + j
		lsl	offset, offset, 3	//offset = ((i * N) + j)*8
		
		str	d22, [frame, offset, SXTW]	//store the rand number into array[i][j]
		
		add	wJ, wJ, 1	//j++
		b	test1		//go to test1


test2:		cmp	wJ, N		//compare j and size
		b.lt 	loop		//if less go to loop
			

		add	wI, wI, 1	//i++
		mov	wJ, 0		//set j to 0 again

test1:		cmp	wI, N		//compare i and size
		b.lt	test2		//if less go to test2
			
//populates 20% of array with negative doubles
		//calculating 20% of NxN array
		mov	value, 20		//value = 20 (used for 20%)
		mul	amount, N, N		//amount = size^2
		mul	amount, amount, value	//amount = (size * size) * 20
		mov	value, 100		//value = 100
		udiv	amount, amount, value	//amount = ((size * size) * 20) / 100
 
		mov	wI, 0		//reset i

		b	test5		//go to test5

loop3:		bl	rand			//use rand function from C (used to make random coordinates within range)
		udiv	xJ, x0, xN		//quotient = rand() / size
		msub	xJ, xJ, xN, x0		//x = quotient - (rand() * size)		
		bl	rand		
		udiv	temp, x0, xN		//quotien = rand()/ size
		msub	temp, temp, xN, x0	//y = quotient - (rand() * size)		

		mul	offset, wJ, N		//offset = x * N
		add	offset, offset, wTemp	//offset = (x * N) + y
		lsl	offset, offset, 3	//offset = ((x * N) + y) * 8
		
		ldr	d22, [frame, offset, SXTW]	//d22 = element
		fneg	d22, d22			//make th element negative
		str	d22, [frame, offset, SXTW]	//store the negative back into original place
		
		add	wI, wI, 1		//i++

test5:		cmp	wI, amount	//compare i and amount
		b.lt	loop3		//go to loop3
	
//populates array with ! and $ surprise
		mov	wI, 0		//reset i
		mov	value, 1	//this is the sign
		adr	timer, surprise
		ldr	d25, [timer]	//d25 = 50.00 

		b	test6		//go to test 6
loop4:		bl	rand		//use rand
		//generate random numbers to find random coordiniates
		udiv	xJ, x0, xN		
		msub	xJ, xJ, xN, x0		//x = rand() % size
		bl	rand			
		udiv	temp, x0, xN
		msub	temp, temp, xN, x0	//y = rand() % size
		
		mul	offset, wJ, N		//offset = N * x
		add	offset, offset, wTemp	//offset = N * x + y
		lsl	offset, offset, 3	//offset = (N * x + y) * 8
		
		str	d25, [frame, offset, SXTW]	//element = 50.00 or -50.00
		fneg	d25, d25			//change to -50.00
		add	wI, wI, 1			//i ++
		

test6:		cmp	wI, 2			//itterate loop twice
		b.lt	loop4			//go to loop4 if less

//populate array with one timer surprise
		adr	timer, time_surprise	
		ldr	d25, [timer]		//d25 = 60.00
		
		bl	rand	
		udiv	xJ, x0, xN
		msub	xJ, xJ, xN, x0		//x = rand()/size
		bl	rand
		udiv	temp, x0, xN
		msub	temp, temp, xN, x0	//y = rand()/size
		
		mul	offset, wJ, N		//offset = N * x
		add	offset, offset, wTemp	//offset = N * x + j
		lsl	offset, offset, 3	//offset = (N * x + j) * 8
		
		str	d25, [frame, offset, SXTW]	//element = 60.00

		mov	w0, 0		//exit
		ldp	fp, lr, [sp], 16
		ret	

//this subroutine is used to display to the user what is in the NxN array (either X, !, @, $, + or -) (param1, param2)
//also displays timer and score
//param1 is the fp
//parma2 is the size of the array
display:	stp 	fp, lr, [sp, -16]!
		mov	fp, sp
		
		mov	N, w1		//N = size
		mov	wI, 0		//i = 0
		mov	wJ, 0		//j = 0
		mov	frame, x0	//frame = fp
				
		add	temp, frame, array_s	//temp is address of array

		b	test3		//goto test3

loop2:		mul	offset, wI, N		//offset = N * i
		add	offset, offset, wJ	//offset = (N * i) + j
		lsl	offset, offset, 3	//offset = ((N * i) + j) * 8
		ldr	d20, [temp, offset, SXTW]	//d20 is element
		
		adr	timer, hund
		ldr	d25, [timer]		//d25 is 100.00
		fcmp	d20, d25		//compare element and 100.00
		b.ge	greater100		//if >= then go to greater100
		fneg	d25, d25		//d25 is -100.00
		fcmp	d20, d25		//compare element and -100.00
		b.le	less100			//if <= then go to less100
		
		adrp	x0, starSign		
		add	x0, x0, :lo12:starSign
		bl	printf			//print "X"
		b	next			//go to next 

//checks if element is >100 or ==100
greater100:	adr	timer, hund		
		ldr	d25, [timer]		//d25 = 100
		fcmp	d20, d25		//compare element and 100
		b.eq	plus			//if equal go to plus
		
		adr	timer, twoHund		
		ldr	d25, [timer]		//d25 = 200
		fcmp	d20, d25		//compare element and 200
		b.eq	money			//if equal go to money
		
		//else print @ sign (value of 250)
		adrp	x0, atSign		
		add	x0, x0, :lo12:atSign	
		bl	printf
		b	next			//go to next

plus:		adrp	x0, plusSign
		add	x0, x0, :lo12:plusSign
		bl	printf			//prints out +
		b	next			//go to next

money:		adrp	x0, moneySign		
		add	x0, x0, :lo12:moneySign
		bl	printf			//print out $
		b	next			//go to nxt

//checks if element is <-100 or ==-100
less100:	adr	timer, hund		
		ldr	d25, [timer]		//d25 = 100
		fneg	d25, d25		//d25 = -100
		fcmp	d20, d25		//compare element and -100
		b.eq	minus			//if equal go to minus
		
		adr	timer, twoHund		
		ldr	d25, [timer]		//d25 = 200
		fneg	d25, d25		//d25 = -200
		fcmp	d20, d25		//compare element and -200
		b.eq	exclaim			//if equal go to exclaim

minus:		adrp	x0, minusSign		
		add	x0, x0, :lo12:minusSign
		bl	printf			//print out -
		b	next			//go to next

exclaim:	adrp	x0, exSign		
		add	x0, x0, :lo12:exSign
		bl	printf			//print out !
		b	next			//go to next
		
next:		add	wJ, wJ, 1		//j++
		b	test3			//goto test3

test4:		cmp	wJ, N			//compare j and size
		b.lt	loop2			//if less go to loop
	
		adrp	x0, newLine		
		add	x0, x0, :lo12:newLine
		bl	printf			//print \n using printf function

		add	wI, wI, 1		//i++
		mov	wJ, 0			//reset j

test3:		cmp	wI, N			//compare i with size
		b.lt	test4			//if less go to test4

		//print out the score
		add	temp, frame, score_s
		ldr	d0, [temp]		//d0 = score
		adrp	x0, showScore
		add	x0, x0, :lo12:showScore
		bl	printf			//print out the score
		
		//print out the timer
		add	temp, frame, timer_s	//temp = address for timer
		ldr	timer, [temp]		//timer = started time
		
		mov	x0, xzr			//x0 = 0 for next function
		bl	time			//use time
		sub	timer, x0, timer	//timer = currentTime - startTime
		mov	givenTime, 12		
		mul	givenTime, givenTime, xN//given time = size * 12
		sub	timer, givenTime, timer	//makes timer count down not up
		
		cmp	timer, 0		//comopare timer and 0
		b.le	timeZero		//if <= then go to timeZero
		b	printTime		//else go to printTime
timeZero:	mov	timer, 0		//if less tha or equal to 0 make timer = 0, so that its not negative number
		
printTime:	mov	x1, timer		//x1 = timer
		adrp	x0, showTimer
		add	x0, x0, :lo12:showTimer
		bl	printf			//print out the timer

		mov	w0, 0			//exit
		ldp	fp, lr, [sp], 16
		ret

//this subroutine takes the x, y coordinates, adds it to the score or time, and marks it as read
//calculates score and time
//param1 is fp
//param2 is the size of the array
//param3 is x
//param4 is y
calculateScore:	stp	fp, lr, [sp, -16]!
		mov	fp, sp
		
		mov	N, w1		//N is size
		mov	wI, w2		//wI is x
		mov	wJ, w3		//wJ is y
		mov	frame, x0	//frame is fp		

		adr	temp, hund
		ldr	d28, [temp]	//d28 is 100.00
		adr	temp, thirty
		ldr	d27, [temp]	//d27 is 30.00
	
		add	temp, frame, timer_s 
		ldr	timer, [temp]	//load timer
		mov	x0, xzr		//x0 = 0 for next function
		bl	time		//use time
		sub	timer, x0, timer//timer = currenttime - starttime
		mov	givenTime, 12	
		mul	givenTime, givenTime, xN//giventime = size * 12	

		cmp	timer, givenTime	//check if its passed the timer
		b.ge	forceQuit		//if timer is passed its given time then go to force quit
				
		//check if user force quit
		cmp	xI, 111			//check is x = 111
		b.eq	checkY			//if x == 111, now check y
		b	noQuit			//else go to no quit
checkY:		cmp	xJ, 111			//check if y is also 111
		b.eq	forceQuit		//if both are 111, go to force quit

noQuit:		mul	offset, wI, N		//offset = N * x
		add	offset, offset, wJ	//offset = N * x + y
		lsl	offset, offset, 3	//offset = (N * x + y) * 8
		
		add	temp, frame, array_s		//temp = address of array
		ldr	d19, [temp, offset, SXTW]	//d19 is element
		
		fcmp	d19, d27		//compare element with 30.00
		b.lt	lowerBound		//check is its less than 30 (original floating points are from -15 to 15)
		b	greaterThan		//if its not less than then its greater than
lowerBound:	fneg	d27, d27		//-30.00
		fcmp	d19, d27		//compare element and -30
		b.gt	inRange			//if greater than then go to inRAnge (in between -30 and 30) = uncovered
		b	lessThan		//if its not greater than then its lessthan
//element is in between -30 and 30
inRange:	fcmp	d19, 0			//check is element is negative
		b.lt	negative		//iff less than 0 then negative
		fcmp	d19, 0			//check if element is positive
		b.gt	positive		//if positive then go to positive

//element is negative above -30 (penalty)
negative:	adrp	x0, bang
		add	x0, x0, :lo12:bang
		fmov	d0, d19			//d0 = element
		bl	printf			//print to user taht penalty has been found
		
		add	temp, frame, score_s	//changing score
		ldr	d20, [temp]		
		fadd	d20, d20, d19		//adding negative to score
		str	d20, [temp]

		add	temp, frame, array_s		//temp = address of array
		fneg	d28, d28			//change to -100.00
		fmov	d21, d28			//d21 = -100
		str	d21, [temp, offset, SXTW]	//putting -100 in element spot so it cant be used again

		b	finish				//go to finish
//element is positive and under 30 (reward)
positive:	adrp	x0, reward
		add	x0, x0, :lo12:reward
		fmov	d0, d19			//d0 = element
		bl	printf			//print to user their reward recieved

		add	temp, frame, score_s	//temp = score address
		ldr	d20, [temp]		//d20 is score
		fadd	d20, d20, d19		//add reward to score
		str	d20, [temp]		//store it in score
		
		add	temp, frame, array_s		//temp is array address
		fmov	d21, d28		
		str	d21, [temp, offset, SXTW]	//marked as read with 100

		b	finish				//go to finish

//type of surprise
greaterThan:	adr	temp, surprise		
		ldr	d20, [temp]		//d20 is 50.00
		adr	temp, time_surprise
		ldr	d21, [temp]		//d21 is 60.00

		fcmp	d19, d20		//check is element is a good surprise
		b.eq	doubleScore		//if it is then go to doublescore
		fcmp	d19, d21		//check if element is a time surprise
		b.eq	addTime			//if it is go to addtime

//has been tried element					
uncovered:	adrp	x0, oops		//if greater than both then its been tried (marked elements are greater than 99 and lessthan -99)
		add	x0, x0, :lo12:oops	
		bl	printf			//print that its been opened before
		b	finish			//go to finish
//good surprise
doubleScore:	adrp	x0, dbScore
		add	x0, x0, :lo12:dbScore
		bl	printf			//print out that surprise is found
		
		add	temp, frame, score_s
		ldr	d21, [temp]		//d21 = score
		fcvtns	timer, d21		//convert score to int
		lsl	timer, timer, 1		//score * 2
		scvtf	d21, timer		//convert back to float
		str	d21, [temp]		//store it back into score

		adr	temp, twoHund		
		ldr	d28, [temp]		//d28 = 200.00
		
		add	temp, frame, array_s		//temp = addres of array
		str	d28, [temp, offset, SXTW]	//store 200 into element spot to indicate that its been uncovered
		
		b	finish				//go to finish

//time surprise	
addTime:	adrp	x0, timeAdded		
		add	x0, x0, :lo12:timeAdded
		bl	printf			//tell user taht timer surprise has been found
		
		add	temp, frame, timer_s	//temp = address of timer
		ldr	givenTime, [temp]	//load timer
		add	givenTime, givenTime, 30//add 30 seconds into start timer
		str	givenTime, [temp]	//store it back into timer
	
		adr	temp, twoFifty		
		ldr	d28, [temp]		//d28 is 250	

		add	temp, frame, array_s		//temp = address of array
		str	d28, [temp, offset, SXTW]	//store 250 into spot to indicate that ts been read
	
		b	finish				//go to finish
//for bad surprise
lessThan:	adr	temp, surprise
		ldr	d20, [temp]
		fneg	d20, d20		//d20 is -50.00
		
		fcmp	d19, d20
		b.ne	uncovered		//if d19 != -50.00 go to uncovered (covered is between 99 and -99)

		adrp	x0, hfScore		
		add	x0, x0, :lo12:hfScore
		bl	printf			//print to user taht bad surprise was found
		
		add	temp, frame, score_s	//temp = address of score
		ldr	d21, [temp]		//d21 = score
		fcvtns	timer, d21		//convert score into int
		lsr	timer, timer, 1		//score / 2
		scvtf	d21, timer		//convert back to float
		str	d21, [temp]		//store new score 

		adr	temp, twoHund		
		ldr	d28, [temp]		//d28 = 200
		fneg	d28, d28		//d28 = -200

		add	temp, frame, array_s		//temp = address of array
		str	d28, [temp, offset, SXTW]	//store -200 in spot of element
	
		b	finish				//go to finish

//changes end value to 1 (due to timer or input of 111 111)		
forceQuit:	add	temp, frame, end_s	//temp = address of end
		mov	value, 1		//value = 1
		str	value, [temp]		//end = 1		

finish:		mov	w0, 0			//exit
		ldp	fp, lr, [sp], 16
		ret

//this subroutine checks all elements in the array and checks if they were all uncovered or not (param1, param2)
//param1 is fp
//param2 is size of array
checkAll:	stp	fp, lr, [sp, -16]!
		mov	fp, sp
		
		mov	N, w1		//N is size
		mov	wI, 0		//i = 0
		mov	wJ, 0		//j = 0
		mov	frame, x0	//frame = fp
		
		add	temp, frame, array_s	//temp = address of array		 		
	
		b	test7		//go to test7
	
loop5:		adr	timer, hund
		ldr	d28, [timer]	//d28 = 100.00
		
		mul	offset, wI, N			//offset = i * N
		add	offset, offset, wJ		//offset = i * N + j
		lsl	offset, offset, 3		//offset = (i * N + j) * 8
		
		ldr	d25, [temp, offset, SXTW]	//store element into d25	
		
		fcmp	d25, d28	//compare element and 100.00	
		b.ge	opened
		fneg	d28, d28	//make d28 = -100.00
		fcmp	d25, d28	//compare element and -100.00
		b.le	opened
		b	unopened	//if neither it is unopened element			

opened:		add	wJ, wJ, 1	//j++
		b	test7		//go to test7

test8:		cmp	wJ, N		//compare j and size
		b.lt	loop5
		
		add	wI, wI, 1	//i++
		mov	wJ, 0		//reset j

test7:		cmp	wI, N		//compare i and size
		b.lt	test8
		
		//if all elements are opened then end = 1
		add	temp, frame, end_s
		mov	value, 1
		str	value, [temp]	//end = 1

unopened:	mov	w0, 0		//exit
		ldp	fp, lr, [sp], 16
		ret
	
//this subroutine asks for name input and logs the scores and names into a file (param1, param2, param3)
//param1 is fp
//param2 is checking if its first time or not (1 is first time, 0 is not)
//parram3 is size of array
logFile:	stp	fp, lr, [sp, -16]!
		mov	fp, sp
		
		mov	value, w2	//value is size
		mov	wJ, w1		//wJ is turn (1 = first time, 0 = second time)
		mov	frame, x0	//frame is fp
			
		//creating file if its not there
		adrp	x0, pn
		add	x0, x0, :lo12:pn	//first arg is file name
		adrp	x1, append	
		add	x1, x1, :lo12:append	//second is mode (a+)
		bl	fopen			//open file
		mov	temp, x0		//temp is file pointer
		mov	x0, temp
		bl	fclose			//close file
		
		cmp	wJ, 0			//compare if its first time
		b.eq	secondTime		//if 0 then its second time
		b	firstTime		//if not its first

//appends the score and timer
secondTime:	adrp	x0, pn
		add	x0, x0, :lo12:pn	//first arg is file name
		adrp	x1, append
		add	x1, x1, :lo12:append	//second is mode a+
		bl	fopen			//open file
		mov	temp, x0		//temp is file pointer
		
		add	xI, frame, score_s	
		ldr	d22, [xI]		//d22 is score

		add	xI, frame, timer_s
		ldr	timer, [xI]		//timer is timer
		mov	x0, xzr			//x0 = 0 for next function
		bl	time			//use time
		sub	timer, x0, timer	//timer = current - start
		mov	xGiven, 12			
		mul	xGiven, xGiven, givenTime	//giventime = size * 12
		sub	timer, xGiven, timer		//timer(counting down) = given - timer(counting up)
		
		cmp	timer, 0		//check if timer is <= 0
		b.le	timeZr			//if it is go to timeZr
		b	notZero			//if not go to notZero
timeZr:		mov	timer, 0		//if less than or equal to 0, timer = 0 (prevetns negative numbers)

notZero:	mov	x0, temp		//fisrt arg is filepointer
		adrp	x1, printSec
		add	x1, x1, :lo12:printSec	//second arg is second print statement (score and timer)
		fmov	d0, d22			//score
		mov	x2, timer		//timer
		bl	fprintf			//use fprintf
		
		mov	x0, temp		//move file pointer
		bl	fclose			//close file


firstTime:	adrp	x0, pn			
		add	x0, x0, :lo12:pn	//first arg is file name
		adrp	x1, read
		add	x1, x1, :lo12:read	//second arg is file mode r
		bl	fopen			//open file in read mode
		mov	temp, x0		//temp is file pointer

displayScore:	adrp	x0, howMany	
		add	x0, x0, :lo12:howMany
		bl	printf			//ask how many scores they woud want to see
	
		mov	xI, xzr			//reset xI to 0
	
		adrp	x0, answer
		add	x0, x0, :lo12:answer
		adr	x1, n
		bl	scanf		//scan the answer 
		adr	x1, n
		ldr	xI, [x1]	//xI is answer to how many
	
top:		cmp	wI, 0		//compare amount with 0
		b.le	bottom		//if less or equal go to bottom
		
		adr	x0, p		//type string
		mov	x1, 200		//200 characters
		mov	x2, temp	//file pointer
		bl	fgets		//use fgets function
		
		adr	x0, p		//type string
		adr	x1, p		//x1 is line in file
		adrp	x0, line	
		add	x0, x0, :lo12:line
		bl	printf		//print out to user the topscores
				

		sub	xI, xI, 1	//amount -= 1
		b	top		//go back to top

bottom:		mov	x0, temp	//mov file pointer
		bl	fclose		//closing read mode file
		
		adrp	x0, pn
		add	x0, x0, :lo12:pn	//first arg is file name
		adrp	x1, append		//second is mode append
		add	x1, x1, :lo12:append
		bl	fopen		//openning append mode
		mov	temp, x0	//temp is file pointer
	
		cmp	wJ, 1		//compare turn and 1 (check if first occurence)
		b.eq	askName		//if first, askName
		b	noShow		//else go to noShow

//asks for the name
askName:	adrp	x0, enter
		add	x0, x0, :lo12:enter
		bl	printf		//asks to enter name
			
		adrp	x0, line
		add	x0, x0, :lo12:line
		adr	x1, p		
		bl	scanf		//scans name in type string
		
		adr	x2, p		//third arg is name
		mov	x0, temp	//first arg is file pointer
		adrp	x1, name	//second arg is  "%s"
		add	x1, x1, :lo12:name
		bl	fprintf		//print into file the name
		mov	wJ, 0		//change occurnce to 0
	
noShow:		cmp	wJ, 1		//if 1, go to bottom (to ask for name even though they didnt want to see the scores)
		b.eq	bottom		//go to bottom if equal
	
		mov	x0, temp	//mov file pointer
		bl	fclose		//close file
		
		mov	w0, 0		//exit
		ldp	fp, lr, [sp], 16
		ret	
