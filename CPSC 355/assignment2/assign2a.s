//Name: Daniel Jin
//UCID: 30107081
//This uses no macros and uses a pre-tested loop with the test at the top
//random numbers are from 0-19

		.data
prompt1:	.string "Enter in the amount of random integers you want to sum up: "		//this is used to ask user to input desired amount of random integers
prompt2:	.string "Sum: %d \n"								//this is used to display the sum
prompt3:	.string "Min: %d \n"								//this is used to display the min
prompt4:	.string "Max: %d \n"								//this is used to display the max
randomNum:	.string "%d \n"									//this is used to display the random number
formatIn:	.string "%d"									//this is used to scan the inputted number


n:		.word 0			//this variable is used to save scanned value
		
		.text
        	.balign 4
        	.global main

main:		stp     x29, x30, [sp, -16]!
		mov     x29, sp
		
		mov	x19, 0 		//this is a counter for the while loop
		mov	x21, 0 		//this is for the total sum
		mov	x22, 0 		//this is for the MAX
		mov	x23, 0		//this is for the MIN		
		mov	x24, 20		//this is used for msub (modulus)
        	
		//prints and asks user to enter desired amount
        	adrp    x0, prompt1
        	add     x0, x0, :lo12:prompt1
        	bl      printf
		
		//scans the input
		adrp	x0, formatIn
		add	x0, x0, :lo12:formatIn		
		adr	x1, n
		bl 	scanf

		//this saves the inputted value into x20 
		adr	x1, n
		ldr	x20, [x1]
		mov	x1, x20

		//initialize rng 
		mov 	x0, xzr		//setting x0 as 0
		bl 	time
		bl	srand

test:		cmp	x19, x20	//comparing counter and inputted value
		b.lt	bottom		//if the counter is less than the inputted value then go to bottom
		b	done		//once counter = inputted value go to done

bottom:		bl	rand		//sets random number in x0
		udiv	x1,x0, x24	//integer division of random number and 20
		msub	x1,x1, x24,x0	//multiply substract: x1 = random - (x1 * 20)
		add	x21, x21, x1	//add into the sum

		cmp	x19, 0		//checking counter is 0 (if its the first iteration)
		b.eq	else1		//if counter == 0, go to else1

		cmp	x1, x23		//comparing random number and min number
		b.lt	else2		//if x1 (random number) is less than min, then goes to else2

checkMax:	cmp	x1, x22		//comparing random number and max number
		b.gt	else		//if x1 (random number) is greater than the max, then goes into else

output:		adrp	x0, randomNum
		add	x0, x0, :lo12:randomNum
		bl	printf
	
		add	x19, x19, 1	//adds 1 to the counter
		b	test		//goes back to the top of the loop

else:		mov	x22, x1		//stores new max into max
		b	output		//goes back inside the loop

else1:		mov	x23, x1		//stores min as the first random number
		b	checkMax	//goes to checkMax


else2:		mov	x23, x1		//stores new min into min
		b	checkMax	//goes to checkMax

done:		
		//this prints out the sum
		mov	x1, x21		//sets x1 as sum
		adrp	x0, prompt2
		add	x0, x0, :lo12:prompt2
		bl	printf

		//this prints out the MAX
		mov	x1, x22		//sets x1 as max
		adrp	x0, prompt4
		add	x0, x0, :lo12:prompt4
		bl	printf		

		//this prints out the MIN
		mov	x1, x23		//sets x1 as min
		adrp	x0, prompt3
		add	x0, x0, :lo12:prompt3
		bl	printf

        	mov     w0, 0
exit:	   	ldp     x29, x30, [sp], 16
        	ret
