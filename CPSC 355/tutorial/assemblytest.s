fmt:    .string "Output: %ld\n" 

        .balign 4       
        .global main

main:   stp     x29,x30, [sp,-16]!      

        // Initialize variables
        mov     x19, 2         
        mov     x23, 3         
        // Multiply variables
        mul     x1, x19, x23

        // Print the result            
        adrp    x0, fmt                
        add     x0, x0, :lo12:fmt       
        bl      printf                 
                                        
        // Set up return value of zero from main()
        mov     w0, 0               

exit:   ldp     x29, x30, [sp], 16      
        ret