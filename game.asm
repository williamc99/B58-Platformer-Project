#####################################################################
#
# CSCB58 Winter 2022 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: William Chiu, 1006998493, chiuwil3, will.chiu@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 16
# - Unit height in pixels: 16
# - Display width in pixels: 1024
# - Display height in pixels: 1024 
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.eqv	BASE_ADDRESS 0x10008000
.eqv	BLACK 0x000000 
.eqv	BROWN 0x795548
.eqv	WHITE 0xffffff
	
.eqv	HEIGHT 64
.eqv	WIDTH 64
.eqv	MAX_X 252
	
.eqv	scoreLineY 56

.data
.text
	li $t0, BASE_ADDRESS		# $t0 stores the base address for display
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t2, $t2, scoreLineY

	addi $sp, $sp, -4		# Prepare stack address
	sw $t2, 0($sp)			# Push y value to stack
	addi $sp, $sp, -4		# Prepare stack address
	sw $t1, 0($sp)			# Push colour code to stack
	jal drawLine			# Call drawLine function
	
	li $v0, 10			# Terminate program
	syscall				
	

drawLine:
	# let $t0 = base_address
	# let $t1 = colour code
	# let $t2 = i
	# let $t3 = max length
	# let $t4 = y value
	# let $t5 = address of pixel
	# let $t6 = address of pixel + base address
	# let $t7 = y * width
	
	lw $t1, 0($sp)			# Pop colour code form stack and store in $t1
	addi $sp, $sp, 4			# Update stack address
	lw $t4, 0($sp)			# Pop y value from stack and store in $t4
	addi $sp, $sp, 4			# Update stack address
	add $t2, $zero, $zero		# $t2 holds value of i 
	addi $t3, $zero, 252		# Let $t3 hold the max length
	sll $t7, $t4, 8			# Multiply y value by 256 to get y*width*4	
	
drawLineLoop:
	add $t5, $t7, $t2		# $t5 = y*width + x		
	add $t6, $t5, $t0		# $t6 = address of pixel + base address
	sw $t1, 0($t6)			# Paint the pixel
	addi $t2, $t2, 4			# Increment index by 4
	ble $t2, $t3, drawLineLoop	# Continue loop if i <= 252
	jr $ra				# Jump back to line that called us






