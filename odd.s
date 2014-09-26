.data
.align 2

prompt: 
	.asciiz "Enter: "

message:
	.asciiz "You said: "

space:
	.asciiz " "


.text

exit:
	li $v0, 10 #exit
	syscall

loop:
	#a1 = remaining
	#a0 = cur_num
	
	beqz $a1, exit
	
	li $v0, 1
	syscall
	
	move $t0, $a0
	la $a0, space
	
	li $v0, 4
	syscall
	
	move $a0, $t0
	
	addi $a0, 2
	sub $a1, $a1, 1
	
	
	j loop

main:
	la $a0, prompt # load prompt into register
	li $v0, 4 # SC: print string
	syscall # print prompt
	
	li $v0, 5 # SC: read int
	syscall # read int
	
	move $a1, $v0
	li $a0, 1 # set 1 as start of number

	jal loop