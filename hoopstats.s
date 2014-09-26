.data

newline:		.asciiz "\n"
space:			.asciiz " "

num_of_entries_prompt:	.asciiz "Please enter the number of entries: "
name_prompt:			.asciiz "Please enter the player's name: "
points_prompt:			.asciiz "Please enter the player's points: "
time_prompt:			.asciiz "Please enter the player's time: "

.text

exit:
	li $v0, 10 #exit
	syscall

prompt_num_entries:
	la $a0, num_of_entries_prompt
	
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall # read value
	
	jr $ra

get_input:
	# a0 = num_entries
	# a1 = heap pointer
	move $s0, $a0
	move $s1, $a1 # I don't want these interfering with syscall args
	
	##
	# READ NAME
	##
	
	
	li $v0, 4
	la $a0, name_prompt
	syscall
	
	li $v0, 8
	li $a1, 30
	move $a0, $s1
	syscall
	
	addi $s1, $s1, 32 # 30 bytes for name
	addi $t5, $t5, 32
	
	##
	# READ POINTS
	##
	
	li $v0, 4
	la $a0, points_prompt
	syscall
	
	li $v0, 6
	syscall
	s.s $f0, 0($s1)
	
	addi $s1, $s1, 4 # 4 bytes for points
	addi $t5, $t5, 4
	
	##
	# READ TIME
	##
	
	li $v0, 4
	la $a0, time_prompt
	syscall
	
	li $v0, 6
	syscall
	s.s $f0, 0($s1)
	
	addi $s1, $s1, 4 # 4 bytes for time
	addi $t5, $t5, 4
	
	addi $s0, $s0, -1
	
	li $v0, 0
	
	move $a0, $s0
	move $a1, $s1
	
	bnez $s0, get_input
	
	move $v0, $s1
	
	jr $ra

parse_input:
	# a0 = number of entries
	# a1 = filled mem
	
	l.s $f4, 32($a1) # points
	l.s $f2, 36($a1) # time
	
	div.s $f6, $f4, $f2

	s.s $f6, 32($a1)
	
	addi $a1, $a1, 40
	
	addi $a0, $a0, -1
	bnez $a0, parse_input
	
	move $v0, $a1
	
	jr $ra

sort_list:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	
	li $v0, 4
	la $a0, 0($a1)
	syscall
	
	l.s $f6 32($a1) # ratio
	
	li $v0, 2
	mov.s $f12, $f6
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	lw $ra 0($sp)
	lw $a0 4($sp)	
	addi $sp, $sp, 8
	
	
	addi $a1, $a1, 40 
	addi $a3, $a3, 40
	blt $a3, $a2, sort_list	
	
	jr $ra	

	

main:
	li $t0, 40 # 32 bytes for name, 4 for points, 4 for time
	li $t1, -1 # -1 for negating numbers
	jal prompt_num_entries # $v0 is the number of entries
	move $s0, $v0 # save $v0 in $t0 temp register | number of entries [see later]
	
	mul $t0, $t0, $s0

	li $v0, 9
	move $a0, $t0
	syscall
	
	move $a0, $s0
	move $a1, $v0
	
	addi $sp, $sp, -8
	sw $t0, 0($sp)
	sw $s0, 4($sp)
	
	jal get_input
	
	lw $t0, 0($sp)
	lw $s5, 4($sp)
	addi $sp, $sp, 8 
	
	move $s0, $v0
	mul $t2, $t0, $t1
	
	add $s0, $s0, $t2
	
	# $s0 memory is now filled with information
	# it is not categorized. I am going to do that now.
	
	
	
	mul $s1, $a0, $t4
	
	addi $sp, $sp, -8
	sw $t0, 0($sp)
	sw $s5, 4($sp)
	
	move $a0, $s5 # number of entries
	move $a1, $s0 # memory pointer [filled]
	
	jal parse_input
	
	move $t3, $v0 # PARSED MEMORY [HEAP]
	
	lw $t0, 0($sp) # memory requested for 3(items)
	lw $t2, 4($sp) # number of entries
	
	addi $sp, $sp, 8
	
	
	li $t1, -1
	mul $t1, $t0, $t1
	add $t3, $t3, $t1
	
	addi $sp, $sp, -8
	
	sw $t0, 0($sp) # memory requested
	sw $t2, 4($sp) # num of entries
	
	move $a0, $t2
	move $a1, $t3
	move $a2, $t0
	li $a3, 0
	li.s $f4, 0.0
	
#mul $a2, $t2, $t2
	
	jal sort_list
	
	lw $t0, 0($sp)
	lw $t1, 0($sp)
	
	addi $sp, $sp, 8

	j exit