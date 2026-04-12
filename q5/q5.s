.section .rodata
filename: .string "input.txt"
filemode: .string "r"
yes: .string "Yes\n"
no: .string "No\n"

.section .text
.globl main

main:
addi sp, sp, -64 # allocate a 64-byte stack frame 
sd ra, 56(sp) # save the return address
sd s0, 48(sp) # s0 is used to keep the file pointer
sd s1, 40(sp) # s1 is used to keep the left index
sd s2, 32(sp) # s2 is used to keep the right index
sd s3, 24(sp) # s3 for temp storage of left char
sd s4, 16(sp) # s4 for temp storage of right char

lla a0, filename # get file name
lla a1, filemode # get read mode
call fopen # we call fopen in order to open the file
mv s0, a0 # we keep the file pointer so it doesn't get overwritten
mv a0, s0 # we put the file pointer back for fseek to be used now
li a1, 0 # so the offeset is 0
li a2, 2 # as seek_end is 2
call fseek # go to the end of the file

mv a0, s0 # we put the file pointer back into f0 for ftell
call ftell # so we get to know the length
li s1, 0 # now left index = 0
addi s2, a0, -1 # now right index = length - 1


loop:
bge s1, s2, success # now if l>=r then we are done as it is a palindrome

mv a0, s0 # we pass the file pointer
mv a1, s1 # we pass the left index
li a2, 0 # we get seek_set
call fseek # we go to the left index
mv a0, s0 # pass file pointer
call fgetc # get left char
mv s3, a0 # store left char

mv a0, s0 # we pass the file pointer
mv a1, s2 # we pass the right index
li a2, 0 # we get seek_set
call fseek # we go to the right index
mv a0, s0 # pass file pointer
call fgetc # get right char
mv s4, a0 # store right char

bne s3, s4, failure # now as they not equal, then it is a failure
addi s1, s1, 1 # l++
addi s2, s2, -1 # r--
jal x0, loop # continue looping

success:
lla a0, yes # we print yes
call printf # print
jal x0, finish # finish

failure:
lla a0, no # we print no
call printf # print

finish:
mv a0, s0 # pass the file pointer
call fclose # close the file

# now we can just clean the stack frame and return 0
li a0, 0
ld ra, 56(sp)
ld s0, 48(sp)
ld s1, 40(sp)
ld s2, 32(sp)
ld s3, 24(sp)
ld s4, 16(sp)
addi sp, sp, 64 # go back
jalr x0, 0(ra) # return
