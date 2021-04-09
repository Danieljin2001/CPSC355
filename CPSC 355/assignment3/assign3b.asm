//Name: Daniel Jin
//UCID: 301007081
//this program converts decimal to binary
define(decimal_N, x19)		//define x19 as decmial_N
define(binary_N, x20)		//define x20 as binary_N
define(i, x21)			//define x21 as i
define(neg, x22)		//define x22 as neg
define(remainder, x23)		//define x23 as remainder
define(temp, x24)		//define x24 as temp
define(value, x25)		//define x25 as value

		.data
prompt1:        .string "Enter in integer: "            //this is to display asking the user input for decimal number
prompt2:        .string "Result is: %ld\n"              //this displays the result
formatIn:       .string "%ld"                           //this is to scan the inputted deciaml number (long integer)

n:              .word 0                 //this variable is used to save the scanned variable

                .text
                .balign 4
                .global main

main:           stp     x29, x30, [sp, -16]!
                mov     x29, sp

                mov     binary_N, 0          	//binary number that will be outputted
                mov     i, 0          		//used to shift "i" many times to the left
                mov     neg, 0         		//used to check if input is negative or not (neg = 1, pos = 0)
                mov     value, -1	        //used to multiply or divide (value changes)

                //prints and asks user to enter a desired amount
                adrp    x0, prompt1
                add     x0, x0, :lo12:prompt1
                bl      printf          //calling printf function from C

                //scans the input
                adrp    x0, formatIn
                add     x0, x0, :lo12:formatIn
                adr     x1, n           //saving n into x1
                bl      scanf           //calling scanf function from C

                //saving inputted value into x19
                adr     x1, n          			//saving n into x1
                ldr     decimal_N, [x1]       		//loading address of x1 to decimal_N

                cmp     decimal_N, 0         		//comparing decimal_N with 0
                b.lt    negative        		//if decimal_N is less than 0, go to negative branch
                b       start           		//else go to start

negative:       mov     neg, 1          		//changing neg to 1
                mul     decimal_N, decimal_N, value   	//times decimal_N by -1 to make it positive

start:          cmp     decimal_N, 0          		//comparing decimal_N and 0
                b.eq    done            		//if decimal_N equals 0, go to done

                mov     value, 2          		//now let value = 2, used for mult or div

                udiv    remainder, decimal_N, value   	//temporarily let remainder equal decimal_N/2
                mul     temp, remainder, value   	//temp = decimal_N * 2

                cmp     temp, decimal_N        		//compare temp and decimal_N
                b.eq    noRemainder     		//if temp == decmial_N, go to noRemainder branch
                mov     remainder, 1          		//else remainder = 0
                b       bottom          		//go to bottom branch

noRemainder:    mov     remainder, 0          		//remainder = 0

bottom:         udiv    decimal_N, decimal_N, value   	//divide decimal_N by 2 (to decrease the value)
                lsl     remainder, remainder, i   	//logically shift left remainder by value of i
                orr     binary_N, binary_N, remainder   //changes 0's to 1's depending if remainder has 0 or 1

                add     i, i, 1     			//increase i by 1
                b       start           		//go back to start

done:           cmp     neg, 1          		//compare neg and 1 (to check is negative)
                b.eq    twosComp        		//if neg is 1, go to twosComp branch
                b       print          			//else just go to print branch

twosComp:       mvn     binary_N, binary_N      	//this changes binary_N's zeros to be ones (ones complement)
                add     binary_N, binary_N, 1   	//add one to binary_N (twos complement)

print:          mov     x1, binary_N        		//x1 = binary_N (for print)
                adrp    x0, prompt2
                add     x0, x0, :lo12:prompt2
                bl      printf          		//calls printf function from C


                mov     w0, 0
exit:           ldp     x29, x30, [sp], 16
                ret
                       
