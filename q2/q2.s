.section .rodata
fmt_space: .string " "
fmt_output: .string "%d"
fmt_next: .string "\n"

.section .text
.globl main

main:
addi sp, sp, -80 
sd ra, 72(sp) # save the retur address
sd s0, 64(sp) # s0 is used to keep the count of the command-line arguments
sd s1, 56(sp) # s1 is used to keep the pointer to the argument string
sd s2, 48(sp) # s2 is used to keep the total no. of elements
sd s3, 40(sp) # s3 to keep the input array pointer
sd s4, 32(sp) # s4 to keep the result array pointer
sd s5, 24(sp) # s5 to keep the stack array pointer
sd s6, 16(sp) # s6 to keep the no. of iterations we have gone thorugh
sd s7, 8(sp) # s7 is the stack pointer index 
sd s8, 0(sp) # s8 for temp storage

mv s0, a0 # preserve the count
mv s1, a1 # preserve the pointer

addi s2, s0, -1 # so we can ignore ./a.out
blez s2, finish # we are done as no. of elements are 0

slli a0, s2, 2 # so, the no. of bytes allocated will be 4*n which is bcs the input is of integar type
call malloc # allocate them
mv s3, a0 # keep the input array

slli a0, s2, 2 # so, the no. of bytes allocated will be 4*n which is bcs the input is of integar type
call malloc # allocate them
mv s4, a0 # keep the result array

slli a0, s2, 2 # so, the no. of bytes allocated will be 4*n which is bcs the input is of integar type
call malloc # allocate them
mv s5, a0 # keep the stack array
li s7, 0 # our stack pointer tracker is set to 0
li s6, 0 # we keep i=0

loop:
bge s6, s2, done_result # if the i=n we are done
addi t1, s6, 1 # get i+1
slli t1, t1, 3 # we multiply 8 to take string input as it is 8 bytes
add t1, s1, t1 # go next
ld a0, 0(t1) # get the string pointer
call atoi # now we convert the string to integar
slli t1, s6, 2 # now we multiply i by 4 
add t1, s3, t1 # go to next integar
sw a0, 0(t1) # store it
addi s6, s6, 1 # i++
j loop # continue looping

done_result:
li s6, 0 # reset i=0
get_loop:
bge s6, s2, logic # if i=n, then we start going through the required logic
slli t1, s6, 2
add t1, s4, t1 # we get the address of the result array
li t2, -1 
sw t2, 0(t1) # we fill it with -1 now
addi s6, s6, 1 # i++
j get_loop # continue looping

logic:
addi s6, s2, -1 # so i = n-1
logic_loop:
blt s6, zero, print # i<0, so we are done
slli t1, s6, 2 # multiply i by 4
add t1, s3, t1 # add input base address
lw s8, 0(t1) # get the current integar

pop:
beq s7, zero, done_pop # if the stack is empty, we are done
addi t3, s7, -1 # we get top index
slli t3, t3, 2 # next int
add t3, s5, t3 # load
lw t3, 0(t3) # get the index

slli t4, t3, 2 # next
add t4, s3, t4 # laod
lw t4, 0(t4) # get value of that index
bgt t4, s8, done_pop # if the stack value is greater, we keep it
addi s7, s7, -1 # else we pop
j pop # continue popping

done_pop:
beq s7, zero, push # if stack empty, result is -1
addi t3, s7, -1 # get the top of the stack index
slli t3, t3, 2 # multiply by 4
add t3, s5, t3 # get the stack address
lw t3, 0(t3) # we get the index again 
slli t4, s6, 2 # multiply by 4
add t4, s4, t4 # get value
sw t3, 0(t4) # now we put it into our result array

push:
slli t3, s7, 2 # multiply the top by 4
add t3, s5, t3 # get the address in the stack
sw s6, 0(t3) # push current i to stack
addi s7, s7, 1 # stack top++
addi s6, s6, -1 # we now move left 
j logic_loop

print:
li s6, 0 # reset i=0
print_loop:
bge s6, s2, finish # if i=n we are done
beq s6, zero, printer # skip space for the first element
lla a0, fmt_space # print the space
call printf # print

printer:
lla a0, fmt_output # load the integer format string
slli t1, s6, 2 # i*4
add t1, s4, t1 # get the address of result
lw a1, 0(t1) # get our result for printing
call printf # print
addi s6, s6, 1 #i++
j print_loop # back if next number is there or no

finish:
lla a0, fmt_next
call printf # print new line
# need to clean the stack frame and for returning the 0
li a0, 0
ld ra, 72(sp)
ld s0, 64(sp)
ld s1, 56(sp)
ld s2, 48(sp)
ld s3, 40(sp)
ld s4, 32(sp)
ld s5, 24(sp)
ld s6, 16(sp)
ld s7, 8(sp)
ld s8, 0(sp)
addi sp, sp, 80
jalr x0, 0(ra) # return
