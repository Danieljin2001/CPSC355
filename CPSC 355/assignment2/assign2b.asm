//Name: Daniel Jin
//UCID: 30107081
//This file uses macros and has the test loop at the bottom of the loop (still pretested)


define(counter, x19)		//defines counter as x19
define(input, x20)		//defines input as x20
define(total, x21)		//defines total as x21
define(max, x22)		//defines max as x22
define(min, x23)		//defines min as x23
define(mod, x24)		//defines mod as x24
		
		.data
prompt1:        .string "Enter in the amount of random integers you want to sum up: "          //this is used to ask user to input desired amount of random integers
prompt2:        .string "Sum: %d \n"                                                            //this is used to display the sum
prompt3:        .string "Min: %d \n"                                                            //this is used to display the min
prompt4:        .string "Max: %d \n"                                                            //this is used to display the max
randomNum:      .string "%d \n"                                                                 //this is used to display the random number
formatIn:       .string "%d"                                                                    //this is used to scan the inputted number


n:              .word 0                 	//this variable is used to save scanned value

                .text
                .balign 4
                .global main

main:           stp     x29, x30, [sp, -16]!
                mov     x29, sp

                mov     counter, 0      	//this is a counter for the while loop
                mov     total, 0		//this is for the total sum
                mov     max, 0          	//this is for the MAX
                mov     min, 0          	//this is for the MIN
		mov	mod, 20			//this is used for msub (modulus)

                //prints and asks user to enter desired amount
                adrp    x0, prompt1
                add     x0, x0, :lo12:prompt1
                bl      printf

                //scans the input
                adrp    x0, formatIn
                add     x0, x0, :lo12:formatIn
                adr     x1, n
                bl      scanf

                //this saves the inputted value into input
                adr     x1, n
                ldr     input, [x1]
                mov     x1, input

                //initialize rng
                mov     x0, xzr         	//setting x0 as 0
                bl      time
                bl      srand
		
		b	test			//go to test

top:		bl	rand			//sets random number in x0
		udiv	x1, x0, mod		//integer division of random number and 20
		msub	x1, x1, mod, x0		//multiply subtract: x1 + random - (x1 * 20)
		add	total, total, x1	//add into the sum
		
		cmp	counter, 0		//checking if counter is 0 (if its the fist iteration)
		b.eq	else1			// if counter ==0, go to else1

		cmp	x1, min			//comparing random number and min number
		b.lt	else2			//if random number is less than the min, then go to else2

		b	checkMax		//go to checkMax


test:           cmp     counter, input  	//comparing counter and inputted value
                b.lt    top	          	//if the counter is less than the inputted value then go to top
                b       done            	//once counter = inputted value go to done


checkMax:       cmp     x1, max         	//comparing random number and max number
                b.gt    else            	//if x1 (random number) is greater than the max, then goes into else

output:         adrp    x0, randomNum
                add     x0, x0, :lo12:randomNum
                bl      printf

                add     counter, counter, 1     //adds 1 to the counter
                b       test            	//goes back to the top of the loop

else:           mov     max, x1         	//stores new max into max
                b       output          	//goes back inside the loop

else1:          mov     min, x1         	//stores min as the first random number
                b       checkMax        	//goes to checkMax


else2:          mov     min, x1         	//stores new min into min
                b       checkMax        	//goes to checkMax

done:
                //this prints out the sum
                mov     x1, total         	//sets x1 as sum
                adrp    x0, prompt2
                add     x0, x0, :lo12:prompt2
                bl      printf

                //this prints out the MAX
                mov     x1, max         	//sets x1 as max
                adrp    x0, prompt4
                add     x0, x0, :lo12:prompt4
                bl      printf

                //this prints out the MIN
                mov     x1, min         	//sets x1 as min
                adrp    x0, prompt3
                add     x0, x0, :lo12:prompt3
                bl      printf

                mov     w0, 0
exit:           ldp     x29, x30, [sp], 16
                ret
