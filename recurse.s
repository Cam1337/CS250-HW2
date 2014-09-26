.data
.align 2

data_prompt:
	.asciiz "Please enter a number: "

.text

exit:
	li $v0, 10 #exit
	syscall

prompt:
	li $v0, 4 # SC: print string
	syscall # print prompt
	li $v0, 5 # SC: read int
	syscall # read int
	jr $ra

f:
	addi $a0, $a0, -1 # N - 1

	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	
	bnez $a0, else
	li $v0, 3
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	
	jr $ra
		
else:
	jal f
	
	lw $a0, 4($sp)
	add $v0, $v0, $a0
	
	lw $ra 0($sp)
	addi $sp, $sp, 8
	jr $ra

main:
	la $a0, data_prompt
	jal prompt
	
	move $a0, $v0
	jal f
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	j exit