# Example program to calculate the cSide for each
# right triangle in a series of right triangles
# given the aSides and bSides using the
# Pythagorean theorem.
# Pythagorean theorem:
# cSide = sqrt ( aSide^2 + bSide^2 )
# Provides examples of MIPS procedure calling.
# -----------------------------------------------------
# Data Declarations
.data
aSides: .word 19, 17, 15, 13, 11, 19, 17, 15, 13, 11
.word 12, 14, 16, 18, 10
bSides: .word 34, 32, 31, 35, 34, 33, 32, 37, 38, 39
.word 32, 30, 36, 38, 30
cSides: .space 60
length: .word 15
min: .word 0
max: .word 0
sum: .word 0
ave: .word 0
# -----------------------------------------------------
# text/code section
.text
.globl main
.ent main
main:
# -----
# Main program calls the cSidesStats routine.
# The HLL call is as follows:
# cSidesStats(aSides, bSides, cSides, length, min,
# max, sum, ave)
# Note:
# The arrays are passed by reference
# The length is passed by value
# The min, max, sum, and ave are pass by reference.
la $a0, aSides # address of array
la $a1, bSides # address of array
la $a2, cSides # address of array
lw $a3, length # value of length
la $t0, min # address for min
la $t1, max # address for max
la $t2, sum # address for sum
la $t3, ave # address for ave
subu $sp, $sp, 16
sw $t0, ($sp) # push addresses
sw $t1, 4($sp)
sw $t2, 8($sp)
sw $t3, 12($sp)
jal cSidesStats # call routine
addu $sp, $sp, 16 # clear arguments
# -----
# Done, terminate program.
li $v0, 10 # terminate
syscall # system call
.end main
# -----------------------------------------------------
# Function to calculate the cSides[] for each right
# triangle in a series of right triangles given the
# aSides[] and bSides[] using the Pythagorean theorem.
# Pythagorean theorem formula:
# cSides[n] = sqrt ( aSides[n]^2 + bSides[n]^2 )
# Also finds and returns the minimum, maximum, sum,
# and average for the cSides.
# Uses the iSqrt() routine to find the integer
# square root of an integer.
# -----
# Arguments:
# $a0 - address of aSides[]
# $a1 - address of bSides[]
# $a2 - address of cSides[]
# $a3 - list length
# ($fp) - addr of min
# 4($fp) - addr of max
# 8($fp) - addr of sum
# 12($fp) - addr of ave
# Returns (via passed addresses):
# cSides[]
# min
# max
# sum
# ave
.globl cSidesStats
.ent cSidesStats
cSidesStats:
subu $sp, $sp, 24 # preserve registers
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $fp, 16($sp)
sw $ra, 20($sp)
addu $fp, $sp, 24 # set frame pointer
# -----
# Loop to calculate cSides[]
# Note, must use $s<n> registers due to iSqrt() call
move $s0, $a0 # address of aSides
move $s1, $a1 # address of bSides
move $s2, $a2 # address of cSides
li $s3, 0 # index = 0
cSidesLoop:
lw $t0, ($s0) # get aSides[n]
mul $t0, $t0, $t0 # aSides[n]^2
lw $t1, ($s1) # get bSides[n]
mul $t1, $t1, $t1 # bSides[n]^2
add $a0, $t0, $t1
jal iSqrt # call iSqrt()
sw $v0, ($s2) # save to cSides[n]
addu $s0, $s0, 4 # update aSides addr
addu $s1, $s1, 4 # update bSides addr
addu $s2, $s2, 4 # update cSides addr
addu $s3, $s3, 1 # index++
blt $s3, $a3, cSidesLoop # if indx<len, loop
# -----
# Loop to find minimum, maximum, and sum.
move $s2, $a2 # strt addr of cSides
li $t0, 0 # index = 0
lw $t1, ($s2) # min = cSides[0]
lw $t2, ($s2) # max = cSides[0]
li $t3, 0 # sum = 0
statsLoop:
lw $t4, ($s2) # get cSides[n]
bge $t4, $t1, notNewMin # if cSides[n] >=
# item -> skip
move $t1, $t4 # set new min value
notNewMin:
ble $t4, $t2, notNewMax # if cSides[n] <=
# item -> skip
move $t2, $t4 # set new max value
notNewMax:
add $t3, $t3, $t4 # sum += cSides[n]
addu $s2, $s2, 4 # update cSides addr
addu $t0, $t0, 1 # index++
blt $t0, $a3, statsLoop # if indx<len, loop
lw $t5, ($fp) # get address of min
sw $t1, ($t5) # save min
lw $t5, 4($fp) # get address of max
sw $t2, ($t5) # save max
lw $t5, 8($fp) # get address of sum
sw $t3, ($t5) # save sum
div $t0, $t3, $a3 # ave = sum / len
lw $t5, 12($fp) # get address of ave
sw $t0, ($t5) # save ave
# -----
# Done, restore registers and return to calling routine.
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $fp, 16($sp)
lw $ra, 20($sp)
addu $sp, $sp, 24
jr $ra
.end cSidesStats
# -----------------------------------------------------
# Function to compute integer square root for
# an integer value.
# Uses a simplified version of Newtons method.
# x = N
# iterate 20 times:
# x' = (x + N/x) / 2
# x = x'
# -----
# Arguments
# $a0 - N
# Returns
# $v0 - integer square root of N
.globl iSqrt
.ent iSqrt
iSqrt:
move $v0, $a0 # $v0 = x = N
li $t0, 0 # counter
sqrLoop:
div $t1, $a0, $v0 # N/x
add $v0, $t1, $v0 # x + N/x
div $v0, $v0, 2 # (x + N/x)/2
add $t0, $t0, 1
blt $t0, 20, sqrLoop
jr $ra
.end iSqrt