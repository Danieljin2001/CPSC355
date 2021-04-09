//Name: Daniel Jin
//UCID: 30107081
//This program generates a table of random positive integers. Each integer must not exeed 100.
//this dimensions of this NxN table is specified by the user. N should not exeed 10.
define(xN, x19)		//defines x19 as xN (this is the inputted size of the array held in x register)
define(N, w19)		//defines w19 as n (inputted size but in w register)
define(row, w20)	//defines w20 as row (used to know index of the row)
define(col, w21)	//defines w21 as col (used to know index of the column)
define(address, x22)	//defines x22 as address (used to know the address of the NxN array)
define(temp, x23)	//defines x23 as temp (used to know the address of the struct showing row, and struct showing columns)
define(offset, w24)	//defines w24 as offset (used to know the offset for the arrays)
define(sum1, w25)	//defines w25 as sum1 (used for the sum of a row or column)
define(max1, w26)	//defines w26 as max1 (used for the max of row or column)
define(xRandNum, x27)	//defines x27 as xRandNum (used to know the random number generated and stored in x register)
define(randNum, w27)	//defines w27 as randNum (used to know random number but in w register)
define(min1, w28)	//defines w28 as min1 (used ot know min of row or columnn)


		.data	//makes it able to read and write
input:		.string	"Enter in the size of the NxN array: "				//used to ask for input
printRow:	.string	"Row %d: has a sum of %d, max of %d and a min of %d\n"		//used to show sum, max and min of a row 
printCol:	.string	"Column %d: has a sum of %d, max of %d and a min of %d\n"	//used to show sum, max and min of a column 
formatIn:	.string "%d"								//used to scan the number
random:		.string "%d\t"								//used to print out the numbers in the array
space:		.string "\n"								//used to make new line when needed

n:	.word 0
	
	.text
	.balign 4
	.global main


//random array
array_count = 10		//max count of array is 10
array_size = 10 * 10 * 4	//array_size = max #rows * max #columns * size int
row_size = 4			//size is int (4 bytes)
col_size = 4			//size is int (4 bytes)

row_s = 16			//offset counts the x29 and x30 registers (8 bytes each)
col_s = 16 + row_size		//offset also counts for 4 bytes (rows)
array_s = row_s + row_size + col_size	//offset also counts for another 4 bytes (cols)
var_size = array_size + row_size + col_size	//size of memory needed is size of array, row counter, and  col counter
alloc = -(16+var_size) & -16			//make is decrement and dvisible by 16


//struct array
sum = 0		//sum starts at 0
max = 4		//sum is int so add 4 bytes
min = 8		//max is also 4 bytes so add another 4bytes
struct_size = 12	//min is also 4 bytes so add another 4, size = 12
structArray_count = 10	//max count of the array is 10
structArray_size = structArray_count * struct_size + structArray_count * struct_size	//array size is struct_size * array_count * 2 )because there are two arrays
rowStruct_s = array_s + array_size		//address for row struct is array address + array size
colStruct_s = rowStruct_s + (10*3*4)  		//address for col struct is row_struct + rowstruct_size


allocateMore = -(var_size + structArray_size) & -16	//this is used to allocate more memory for the struct arrays
dealloc = -alloc	// to deallocate negate the amount allocated

fp	.req	x29	//x29 is fp 
lr	.req	x30	//x30 is lr

main:	stp	fp, lr, [sp, alloc]!	//allocate memory
	mov	fp, sp			//fp equals stack pointer


ask:	adrp	x0, input		//ask for size of array
	add	x0, x0, :lo12:input
	bl	printf			//use printf function in C
	
	adrp	x0, formatIn		//scan the number
	add	x0, x0, :lo12:formatIn
	adr	x1, n			//store it in x1
	bl	scanf			//call scanf function in C
	
	adr	x1, n			
	ldr	xN, [x1]		//load number into xN
	mov	x1, xN			
	
	cmp	xN, 10			//compare xN and 10 (check is its greater than 10)
	b.gt	ask			//if greater than 10 ask again
	
	add	sp, sp, allocateMore	//allocate more memory for struct arrays

	mov	row, 0			//row = 0 (counter and index)
	str	row, [fp, row_s]	//store it into address 
	mov	col, 0			//col = 0
	str	col, [fp, col_s]	//store it into address
					
					//initially:	
	mov	sum1, 0			//sum = 0
	mov	max1, 0			//max = 0
	mov	min1, 100		//min = 0

	SXTW	xN, N			//make it a w register
	
	mov	x0, xzr			//used x0 = 0
	bl 	time			//use time function in C
	bl	srand			//use srand function in C

	b	test1			//first branc to test1
	
loop:	bl 	rand			//use rand function in C
	and	xRandNum, x0, 0xf	//random % 16, numbers will be 0 to 15 (randomnumber was in x0)

	mov	x1, xRandNum		//x1 is xRandnum
	adrp	x0, random		//print out the number
	add	x0, x0, :lo12:random	
	bl	printf			//use printf function in C
	
		
	ldr	row, [fp, row_s]	//load the counter/index of row in address		
	ldr	col, [fp, col_s]	//load the counter/index of col in address
	add	address, fp, array_s	//array base address	

	mul	offset, row, N		//offset = row * N
	add	offset, offset, col	//offset = (i * N) + col
	lsl	offset, offset, 2	//offset = ((i * N) + col) * 4

	str	randNum, [address, offset, SXTW]	//store rand in array[row][col]

	
	add	col, col, 1		//col++
	str	col, [fp, col_s]	//store new col value in address
	
	add	sum1, sum1, randNum	//adding to sum
	cmp	randNum, max1		//compare randNum with max1
	b.lt	next			//if it snot greater got to next
	mov	max1, randNum		//if greater store new max

next:	cmp	randNum, min1		//compare randNum with min1
	b.gt	next2			//if its greater go branch to next2
	mov	min1, randNum		//if less then store new min
	
next2:	b	test1			//go to test1



test2:	cmp	col, N			//compare col and N
	b.lt	loop			//if its less then go back to loop
	
	adrp	x0, space		//print the new line
	add	x0, x0, :lo12:space
	bl	printf			//use printf function from  C
	
	mov	x1, struct_size		//temporarily store the size of struct in x1
	sxtw	x2, row			//temporaily store row into x2

	add	temp, fp, rowStruct_s	//temp = base address of rowStruct
	mul	x2, x2, x1		//row*structsize
	str	sum1, [temp, x2]	//stores sum into sum in rowStruct
	
	add	temp, fp, rowStruct_s	//temporaily store rowstruct address
	sxtw	x2, row			//temp. store row into x2
	mul	x2, x2, x1		//row * structsize
	add	x2, x2, max		//add offset of max
	str	max1, [temp, x2] 	//stores max in rowStruct

	add	temp, fp, rowStruct_s	//temp. store address of rowStruct
	sxtw	x2, row			//temp. let x2 = row
	mul	x2, x2, x1		//row*structSize
	add	x2, x2, min		//add offset of min 
	str	min1, [temp, x2]	//store min in min of rowStruct

	mov	sum1, 0			//reset sum
	mov	max1, 0			//reset max
	mov	min1, 100		//reset min

	add	row, row, 1		//row++
	str	row, [fp, row_s]	//store new row value into address
	mov	col, 0			//reset col to 0
	str	col, [fp, col_s]	//store new value

test1:	cmp	row, N			//check is row is less than N
	b.lt	test2    		//if less, go to test 2
	
	//getting ready to loop through again but got column based

	mov	row, 0		//make row equal 0 again
	mov	col, 0		//make col equal 0 again
	str	row, [fp, row_s]	//store new value of row
	str	col, [fp, col_s]	//store new value of col
	mov	sum1, 0		//reset sum
	mov	max1, 0		//rest max
	mov	min1, 100	//reset min

	b	test3		//go to test 3

	//looping through column based
loop2:	add	address, fp, array_s	//get base address
	
	
	mul	offset, row, N		//offset = row * N
	add	offset, offset, col	//offset = row* N + col
	lsl	offset, offset, 2	//offset = (row*N +col)	* 4

	ldr	w7, [address, offset, SXTW]	//load the value of array[row][col] into w7

	add	row, row, 1		//row++
	str	row, [fp, col_s]	//store new value of row
	
	add	sum1, sum1, w7		//add to the sum
	cmp	w7, max1		//compare max and the element
	b.lt	next3			//if less than then go to next3
	mov	max1, w7		//if greater, set new max

next3:	cmp	w7, min1		//compare min and element
	b.gt	next4			//of greater go to next4
	mov	min1, w7		//if less, set new min

next4:	b	test3			//go to test3

test4:	cmp	row, N			//compare if row is less than N
	b.lt	loop2			//if less go back to loop


	mov	x1, struct_size		//temp. let x1 = structsize
	sxtw	x2, col			//temp. let x2 = col
	
	add	temp, fp, colStruct_s	//get address of col_struct
	mul	x2, x2, x1		//col*struct_size
	str	sum1, [temp, x2]	//store the sum into sum of col_struct
	
	add	temp, fp, colStruct_s	//get address of colStruct
	sxtw	x2, col			//temp let x2 = col
	mul	x2, x2, x1		//col*address
	add	x2, x2, max		//col*address + maxoffset
	str	max1, [temp, x2]	//store max into  max of col_struct

	add	temp, fp, colStruct_s	//get address of colstruct
	sxtw	x2, col			//temp. let x2 = col
	mul	x2, x2, x1		//col*address
	add	x2, x2, min		//col*address + min(offset)
	str	min1, [x23, x2]		//store min in colStruct min
	
	mov	sum1, 0			//reset sum
	mov	max1, 0			//reset max
	mov	min1, 100		//reset min

	add	col, col, 1		//col++
	str	col, [fp, row_s]	//store new value of col
	mov	row, 0			//reset row
	str	row, [fp, col_s]	//store new value of row


test3:	cmp	col, N			//compare col and N
	b.lt	test4			//if less go to test4
	
	mov	row, 0			//reset row (used for struct arrays)
	b 	test5			//go to test5

loop3:	mov	x6, struct_size		//x6 = structSize
		
	mov	w1, row			//w1 = row (to print it out)
	
	add	temp, fp, rowStruct_s	//get address of row struct
	sxtw	x7, row			//temp. let x7 = row
	mul	x7, x7, x6		//row * size
	ldr	w2, [temp, x7]		//get load sum into w2 (to print)
	
	add	temp, fp, rowStruct_s	//get address of row struct
	sxtw	x7, row			//temp. let x7 = row
	mul	x7, x7, x6		//row*size
	add	x7, x7, max		//row*size + max (offset)
	ldr	w3, [temp, x7]		//load the value of max into w3 (to print)

	add	temp, fp, rowStruct_s	//get address of row struct
	sxtw	x7, w20			//temp. get x7 = row
	mul	x7, x7, x6		//row*size
	add	x7, x7, min		//row*size + min (offset)
	ldr	w4, [temp, x7]		//load min into w4 (to print)
	
	adrp	x0, printRow		//print the row sum max and min
	add	x0, x0, :lo12:printRow	
	bl	printf			//use C function
	
	add	row, row, 1		//row ++
test5:	cmp	row, N			//check if row is less than N
	b.lt	loop3			//if less go back to loop
		
	adrp	x0, space		//print newline 
	add	x0, x0,	:lo12:space
	bl	printf			//use C function

	mov	row, 0			//reset row (used for col array)
	b	test6			//go to test6

	//for cols
loop4:	mov	x6, struct_size		//get size of colstruct
	mov	w1, row			//store index into w1 (to print)

	add	temp, fp, colStruct_s	//get colstruct address
	sxtw	x7, row			//temp. x7 = row
	mul	x7, x7, x6		//row * size
	ldr	w2, [temp, x7]		//load sum into w2 (to print)
	
	add	temp, fp, colStruct_s	//get address of colstruct
	sxtw	x7, row			//temp. x7 = row
	mul	x7, x7, x6		//row*size
	add	x7, x7, max		//row*size + max(offset)
	ldr	w3, [temp, x7]		//load the max into w3
	
	add	temp, fp, colStruct_s	//get address of colStruct
	sxtw	x7, row			//temp. let x7 = row
	mul	x7, x7, x6		//row*size
	add	x7, x7, min		//row*size+min(offset)
	ldr	w4, [temp, x7]		//load min into w4
	
	adrp	x0, printCol		//print out the sum max min of column
	add	x0, x0, :lo12:printCol	
	bl	printf			//use C function
	
	add	row, row, 1		///row++

test6:	cmp	row, N			//check is row is less than N
	b.lt	loop4			//of less go back to loop
	
	sub	sp, sp, allocateMore	//deallocate 

exit:	mov	w0, 0			//w0 = o
	ldp	fp, lr, [sp], dealloc	//deallocate
	ret

