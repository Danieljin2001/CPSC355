//Name: Daniel Jin
//UCIDL	30107081
//this program changes from binary to decimal
define(pos_N, x19)			//define x19 as pos_N
define(temp, x20)			//define x20 as temp
define(sign, x21)			//define x21 as sign
define(i, x22)				//define x22 as i
define(decimal_N, x23)			//define x23 as decimal_N
define(pow_2, x24)			//define x24 as pow_2

		.data
prompt1:        .string "Enter in an integer: "         //this is to display asking the user input for a binary number
prompt2:        .string "Result is: %ld\n"              //this displays the result
formatIn:       .string "%ld"                           //this is to scan the inputted binary number (long integer)


n:              .word 0         //this variable is used to save the scanned variable

                .text
                .balign 4
                .global main

main:           stp     x29, x30, [sp, -16]!
                mov     x29, sp


                mov     sign, 1         	//this is used to output a negative or positive number (x21 will be either 1 or -1) in the end
                mov     i, 0        	  	//this is used to be "i" and will go up in increments of one and will be used for 2^i
                mov     decimal_N, 0		//this is the returned value
                mov     pow_2, 1		//base of 2 and exponent increments by 1
                //prints and asks user to enter desired amount
                adrp    x0, prompt1
                add     x0, x0, :lo12:prompt1
                bl      printf                  //calling printf function from C

                //scans the input
                adrp    x0, formatIn
                add     x0, x0, :lo12:formatIn
                adr     x1, n                   //saving n into x1
                bl      scanf                   //calling scanf function from C

                //saving inputted value into x19
                adr     x1, n                   //saving n into x1
                ldr     pos_N, [x1]             //loading address of x1 to pos_N

                lsr     temp, pos_N, 63         //this logically shifts right 63 times, leaving 1 or 0 at least significant digit (to check if negative or not)
                tst     temp, 0x1               //this checks if the least significant digit of temp is 1 or 0.
                b.eq    positive                //if temp is 0 go to positive (because Z == 1)

                mov     sign, -1                //this changes sign to be -1

                //this changes the twos complement of the negative number to be changed back to a postive binary version
                mvn     pos_N, pos_N            //this changes pos_N zeros to be ones
                add     pos_N, pos_N, 1         //this changes pos_N adds one to pos_N

positive:       cmp     i, 64                 	//comparing "i" and 64 (64 bits)
                b.eq    done                    //once "i" reaches 64 it branches to done

                tst     pos_N, 0x1               //this checks if lsb of pos_N is 1 or 0
                b.ne    addon                   //if temp is 1 go to addon (because Z == 0)
		
		ror	pos_N, pos_N, 1		//this rotates the lsb to be the msb, and now there is a new lsb		

                lsl     pow_2, pow_2, 1         //this incremments exponent by 1
                add     i, i, 1             	//this increments "i" by 1
                b       positive                //goes back to loop

addon:          ror	pos_N, pos_N, 1		//this rotates the lsb to be the msb, and now there is a new lsb

		add     decimal_N, decimal_N, pow_2	//decimal_N = decimal_N + pow_2
                lsl     pow_2, pow_2, 1             	//increments exponent by 1

                add     i, i, 1             	//increments "i" by 1
                b       positive                //goes back to loop


done:           mul     decimal_N, decimal_N, sign    	//multiplies deciaml_N with either -1 or 1 (depending if input was negative or not)
                mov     x1, decimal_N                 	//sets x1 as decimal_N value
                adrp    x0, prompt2
                add     x0, x0, :lo12:prompt2
                bl printf				//calling prinf function from C



                mov     w0, 0
exit:           ldp     x29, x30, [sp], 16
                ret
