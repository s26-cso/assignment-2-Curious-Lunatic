.text
.globl make_node
.globl insert
.globl get
.globl getAtMost

make_node:
addi sp, sp, -16 # setting up the stack pointer
sd ra, 8(sp) # saving the return address 
sd s1, 0(sp) # saving the caller register before we use it
mv s1, a0 # move the target integar into a callee register to preserve it

li a0, 24 # now these 24 bytes are there for 4 for the integar, 8 each for the left and right pointer and 4 for padding
call malloc # use it to allocate
sw s1, 0(a0) # we store integar value at the start
sd zero, 8(a0) # we initialize the left pointer to null
sd zero, 16(a0) # we initialize the right pointer to null

# now we just restore the stack frame 
# we also return the new node's address in a0 too
ld s1, 0(sp)
ld ra, 8(sp)
addi sp, sp, 16 # go back
jalr x0, 0(ra) # return



insert:
bne a0, zero, traverse # now if the root is null, we go and create a new one else we traverse through
mv a0, a1 
j make_node  # we then jump (jal x0, make_node) to make_node in order to create the new node

traverse:
addi sp, sp, -32 # we establish a stack frame of 32 bytes to maintain our state
sd ra, 24(sp) # save return address
sd s1, 16(sp) # preserve the root pointer in s1
sd s2, 8(sp) # preserve the target value in s2
mv s1, a0
mv s2, a1
lw t2, 0(s1) # we get the integar value from the current node we are in
bge s2, t2, right_branch # if the target is greater than current we need to move right

left_branch:
ld a0, 8(s1) # get the left pointer
mv a1, s2 # get the value in a1 safely
call insert # we insert it
sd a0, 8(s1)
j finish

right_branch:
ld a0, 16(s1) # get the right pointer
mv a1, s2 # get the value in a1 safely
call insert # we insert it
sd a0, 16(s1)

finish:
# now we just restore the stack frame 
# we also return the new node's address in a0 too
mv a0, s1
ld s2, 8(sp)
ld s1, 16(sp)
ld ra, 24(sp)
addi sp, sp , 32
jalr x0, 0(ra) # return


get:
loop:
beq a0, zero, notfound # so if equal to null then the value is absent
lw t3, 0(a0) # we get the integar from current to compare
beq a1, t3, found # if it is equal then we have found the match
blt a1, t3, go_left # if the required number is smaller, then we go left

go_right:
ld a0, 16(a0) # get the right pointer
j loop # go back and loop

go_left:
ld a0, 8(a0) # get the left pointer
j loop # go back and loop

notfound:
mv a0, zero # so we return 0 if it is failed 
found:
# now a0 has the value so we just reutrn
jalr x0, 0(ra) # return


getAtMost:
# now a0 will have the target, a1 will have the root
li t5, -1 # we need to initialize our tracker to -1

evaluate:
beq a1, zero, best # if we reach null, then our search has reached a terminal leaf of the tree
lw t4, 0(a1) # get the current integar of the node
blt a0, t4, smaller # now if the value is greater than it, then we go to the left subtree for finding the smaller number

larger:
mv t5, t4 # so now this value is there, so we need to update our value tracker
ld a1, 16(a1) # now we go to the right subtree just to see if there is any value just greater that makes sense
j evaluate

smaller:
ld a1, 8(a1) # now we go to the left subtree to check for the values
j evaluate

best:
mv a0, t5 # we get the value from t5 to answer
jalr x0, 0(ra) # return
