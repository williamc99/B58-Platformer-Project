#####################################################################
#
# CSCB58 Winter 2022 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: William Chiu, 1006998493, chiuwil3, will.chiu@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 512
# - Display height in pixels: 512 
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 2/3 (choose the one the applies)
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
.eqv 	WATERBLUE 0x2195f3
.eqv	BUTTONGRAY 0x9e9e9e
.eqv	BUTTONRED 0xff1745
.eqv	BARRIERBROWN 0x4e342e
.eqv	STOPPEDORANGE 0xff5622

.eqv	PPBLUE1	0x2195f3
.eqv	PPBLUE2 	0x40c3ff
.eqv	PPGREEN1 0x4caf4f
.eqv 	PPGREEN2 0x8bc34a
.eqv 	PPVIOLET1 0x661fff
.eqv	PPVIOLET2 0xb488ff
 
.eqv	COINYELLOW 0xffc107
.eqv	COINBLUE 0x40a4f5
 
.eqv	HAIRWHITE 0xf5f5f5
.eqv	LEFTEYE 0xa1887f
.eqv	RIGHTEYE  0xd50000
.eqv	SKINPEACH 0xfce8db
		
.eqv	scoreLineY 56
.eqv 	waterLine1 55
.eqv	waterLine2 54
.eqv	waitDelay 40
.eqv 	maxJumpCount 12

.data
.text

#---------------------------------Initialize Game--------------------------------
initialize:
	addi $s0, $zero, 0		# Store player score
	addi $s1, $zero, 2		# Store player x-value
	addi $s2, $zero, 46		# Store player y-value
	addi $s3, $zero, 2		# Store player old x-value
	addi $s4, $zero, 46 		# Store player old y-value
	addi $s5, $zero, 0		# Store player jump counter
	addi $s6, $zero, 0		# Store inAir value (0 = not mid-jump, 1 = mid-jump)
	addi $s7, $zero, 0		# Store drawCheck (0 = draw, 1 = don't draw character)
	li $t0, BASE_ADDRESS		# $t0 stores the base address for display
		
	jal drawStart			# Draw the screen
	
	
#---------------------------------Main Loop--------------------------------------
main:	
	addi $s7, $zero, 1		# Set drawCheck to 1 ( don't draw)
	move $s3, $s1			# Save old x value
	move $s4, $s2			# Save old y value
	
	# Check for mid-jump/gravity
	beq $s6, $zero, moveGravity	# If not mid jump (inAir = 0), check gravity
	j altMoveUp			# Else, we are mid-jump so move up
	
jumpLookKey:	
	# Check for key press
	li $t9, 0xffff0000		# Load keypressed memory address
	lw $t8, 0($t9)			
	beq $t8, 1, checkKeyPressed	# If key pressed happened, call function
		
jumpKeyPressed:
	# Check coin collisions
checkCoin1:
	# Check coin 1
	li $t1, COINBLUE			# First check if coin 1 is already removed
	lw $t2, 10808($t0)		# Get the colour of the previously white pixel in coin 1
	bne $t2, COINBLUE, checkCoin2	# If already erased, go and check for coin 2
	addi $a0, $zero, 9		# Set arguments for checking coin 1
	addi $a2, $zero, 38
	jal checkCoin			# Check if coin was collided with
checkCoin2:
	# Check coin 2
	li $t1, COINBLUE			# First check if coin 1 is already removed
	lw $t2, 7060($t0)		# Get the colour of the previously white pixel in coin 2
	bne $t2, COINBLUE, checkCoin3	# If already erased, go and check for coin 3
	addi $a0, $zero, 32		# Set arguments for checking coin 2
	addi $a2, $zero, 23
	jal checkCoin			# Check if coin was collided with
checkCoin3:
	# Check coin 3
	li $t1, BLACK			# First check if coin 1 is already removed
	lw $t2, 1980($t0)		# Get the colour of the previously white pixel in coin 3
	bne $t2, COINBLUE, skipCoinChecks	# If already erased, skip coin checks
	addi $a0, $zero, 42		# Set arguments for checking coin 3
	addi $a2, $zero, 3
	jal checkCoin			# Check if coin was collided with
	
skipCoinChecks:				# Else, skip the coin checks
	# Redraw Character
	addi $t5, $zero, 1		
	beq $s7, $t5, noUpdate		# If drawCheck == 1, skip updateCharacte
		
redrawCharacter:
	# Erase object with old coordinates
	move $a1, $s3			# Set old x coordinate of character
	move $a3, $s4			# Set old y coordinate of character
	jal eraseCharacter		# Erase character
	# Redraw character
	move $a1, $s1			# Set new x coordinate of character
	move $a3, $s2			# Set new y coordinate of character
	jal drawCharacter		# Redraw character
	
noUpdate:
	# Sleep
	li $v0, 32			# Load syscall
	li $a0, waitDelay 		# Sleep 
	syscall
	j main				# Loop main


END:	
	li $v0, 10			# Terminate program
	syscall				# Call syscall








#####---------------------------------MOVEMENT FUNCTIONS------------------------------#####

		
# Given colour, and x/y values, check if specified colour is under the player
checkBottom:
	move $t1, $a1			# Store colour
	move $t2, $a2			# Store x
	addi $t3, $a3, 3			# Store y
	addi $v0, $zero, 0		# Set $v0 to 0
	
	sll $t4, $t3, 8			# Multiply y by 256
	sll $t2, $t2, 2			# Nultiply x by 4
	add $t5, $t4, $t2		# y*256 + x
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, ($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkBottomEND	# If colour found, increment and end
	addi $t5, $t5, 4			# Else, go right by one
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, 0($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkBottomEND	# If colour found, increment and end
	addi $t5, $t5, 4			# Else, go right by two
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, 0($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkBottomEND	# If colour found, increment and end
	jr $ra				# Colour not found, return 0
checkBottomEND:
	addi $v0, $zero, 1		# Set $v0 to 1
	jr $ra				# Return
	
	
# Given colour, and x/y values, check if specified colour is above the player
checkTop:
	move $t1, $a1			# Store colour
	move $t2, $a2			# Store x
	addi $t3, $a3, -1		# Store y
	addi $v0, $zero, 0		# Set $v0 to 0
	
	sll $t4, $t3, 8			# Multiply y by 256
	sll $t2, $t2, 2			# Nultiply x by 4
	add $t5, $t4, $t2		# y*256 + x
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, ($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkTopEND	# If colour found, increment and end
	addi $t5, $t5, 4			# Else, go right by one
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, 0($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkTopEND	# If colour found, increment and end
	addi $t5, $t5, 4			# Else, go right by two
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, 0($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkTopEND	# If colour found, increment and end
	jr $ra				# Colour not found, return 0
checkTopEND:
	addi $v0, $zero, 1		# Set $v0 to 1
	jr $ra		
	
		
# Given colour, and x/y values, check if specified colour is on the left of the player
checkLeft:
	move $t1, $a1			# Store colour
	addi $t2, $a2, -1		# Store x
	move $t3, $a3			# Store y
	addi $v0, $zero, 0		# Set $v0 to 0				
							
	sll $t4, $t3, 8			# Multiply y by 256
	sll $t2, $t2, 2			# Nultiply x by 4
	add $t5, $t4, $t2		# y*256 + x
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, ($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkLeftEND	# If colour found, increment and end
	addi $t5, $t5, 256		# Else, go down by one
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, 0($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkLeftEND	# If colour found, increment and end
	addi $t5, $t5, 256		# Else, go down by two
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, 0($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkTopEND	# If colour found, increment and end
	jr $ra				# Colour not found, return 0
checkLeftEND:								
	addi $v0, $zero, 1		# Set $v0 to 1
	jr $ra
	
	
# Given colour, and x/y values, check if specified colour is on the left of the player
checkRight:
	move $t1, $a1			# Store colour
	addi $t2, $a2, 3			# Store x
	move $t3, $a3			# Store y
	addi $v0, $zero, 0		# Set $v0 to 0				
							
	sll $t4, $t3, 8			# Multiply y by 256
	sll $t2, $t2, 2			# Nultiply x by 4
	add $t5, $t4, $t2		# y*256 + x
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, ($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkRightEND	# If colour found, increment and end
	addi $t5, $t5, 256		# Else, go down by one
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, 0($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkRightEND	# If colour found, increment and end
	addi $t5, $t5, 256		# Else, go down by two
	add $t6, $t0, $t5		# $t6 = base address + address of pixel
	lw $t7, 0($t6)			# Load colour address of pixel into $t7
	beq $t7, $t1, checkRightEND	# If colour found, increment and end
	jr $ra				# Colour not found, return 0
checkRightEND:								
	addi $v0, $zero, 1		# Set $v0 to 1
	jr $ra																															
													
	
	
# This function checks for key pressed (assuming a key was pressed)	
checkKeyPressed:	
	lw $t2, 4($t9) 			# Get key value of press
	# Check if left
	beq $t2, 0x61, moveLeft		# ASCII code of 'a' is 0x61 
	# Check if right
	beq $t2, 0x64, moveRight		# ASCII code of 'd' is 0x64
	# Check if up
	beq $t2, 0x77, checkMoveUp	# ASCII code of 'w' is 0x77
	# Check if restart (p)
	beq $t2, 0x70, restartGame	# ASCII code of 'p' is 0x70
	j jumpKeyPressed
	
checkMoveUp:
	# Check for on platform
	li $a1, BROWN			# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkBottom
	bgtz $v0, moveUp			# Check if "w" was pressed mid-jump
	j jumpKeyPressed			# Else, new jump so call function
		
moveLeft:
	addi $t5, $zero, 0		# Store left boundary
	ble $s1, $t5, jumpKeyPressed	# If x = 0, don't update x
	# Check for on platform
	li $a1, BROWN			# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkLeft
	# Else go up one
	addi $s7, $zero, 0		# Set drawCheck to 0
	bgtz $v0, jumpKeyPressed 	# If return greater than 0, don't go up
	addi $s1, $s1, -2		# Move x-value left 1
	j jumpKeyPressed
	
moveRight:
	addi $t5, $zero, 61		# Store right boundary
	addi $t6, $zero, 60		# Store right boundary
	beq $s1, $t6, altMoveRight	# Move right 1 if this exact x value
	bge $s1, $t5, jumpKeyPressed	# If x => 61, don't update x
	# Check for on platform
	li $a1, BROWN			# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkRight
	# Else go up one
	addi $s7, $zero, 0		# Set drawCheck to 0
	bgtz $v0, jumpKeyPressed 	# If return greater than 0, don't go up
	addi $s1, $s1, 2			# Move x-value right 1
	j jumpKeyPressed
altMoveRight:
	addi $s7, $zero, 0		# Set drawCheck to 0
	addi $s1, $s1, 1			# Move x-value right 1
	j jumpKeyPressed
	
moveUp: 
	addi $t6, $zero, maxJumpCount	# Store max jump counter
	beq $s5, $t6, lastMoveUp 	# If jump counter == maxJumpCount
	addi $t5, $zero, 0		# Store top boundary
	beq $s2, $t5, jumpKeyPressed	# If y = 0, don't update y
	# Check for on platform
	li $a1, BROWN			# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkTop
	# Else go up one
	addi $s5, $s5, 1			# Increment jump counter
	addi $s7, $zero, 0		# Set drawCheck to 0
	addi $s6, $zero, 1		# Set inAir to 1
	bgtz $v0, jumpKeyPressed		# If return greater than 0, don't go up
	addi $s2, $s2, -1		# Move y-value up 1
	j jumpKeyPressed
lastMoveUp:
	addi $t5, $zero, 0		# Store top boundary
	beq $s2, $t5, jumpKeyPressed	# If y = 0, don't update y
	# Check for on platform
	li $a1, BROWN			# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkTop
	# Else go up one
	addi $s5, $zero, 0		# Reset jump counter
	addi $s7, $zero, 0		# Set drawCheck to 0
	addi $s6, $zero, 0		# Set inAir to 0
	bgtz $v0, jumpKeyPressed 	# If return greater than 0, don't go up
	addi $s2, $s2, -1		# Move y-value up 1
	j jumpKeyPressed
# Alternate moveUp for the case where mid jump but you still need to check for key press	
altMoveUp: 
	addi $t6, $zero,  maxJumpCount	# Store max jump counter
	beq $s5, $t6, altLastMoveUp 	# If jump counter == maxJumpCount
	addi $t5, $zero, 0		# Store top boundary
	beq $s2, $t5, jumpLookKey	# If y = 0, don't update y
	addi $s5, $s5, 1			# Increment jump counter
	# Check for on platform
	li $a1, BROWN			# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkTop
	# Else go up one
	addi $s7, $zero, 0		# Set drawCheck to 0
	addi $s6, $zero, 1		# Set inAir to 1
	bgtz $v0, jumpLookKey 		# If return greater than 0, don't go up
	addi $s2, $s2, -1		# Move y-value up 1
	j jumpLookKey
altLastMoveUp:
	addi $t5, $zero, 0		# Store top boundary
	beq $s2, $t5, jumpLookKey	# If y = 0, don't update y
	# Check for on platform
	li $a1, BROWN			# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkTop
	# Else go up one
	addi $s5, $zero, 0		# Reset jump counter
	addi $s7, $zero, 0		# Set drawCheck to 0
	addi $s6, $zero, 0		# Set inAir to 0
	bgtz $v0, jumpLookKey 		# If return greater than 0, don't go up
	addi $s2, $s2, -1		# Move y-value up 1
	j jumpLookKey
	
moveGravity: 
	# Check for on platform
	li $a1, BROWN			# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkBottom
	bgtz $v0, noJumper 		# If return greater than 0, set jump counter to 0
	# Else, start gravity
	addi $t5, $zero, 61		# Store bottom boundary
	beq $s2, $t5, jumpKeyPressed	# If y = 61, don't update y
	addi $s7, $zero, 0		# Set drawCheck to 0
	addi $s2, $s2, 1			# Move y-value down 1
	j jumpLookKey			# Return to main	
noJumper:
	addi $s5, $zero, 0		# Set jump counter to 0
	addi $s6, $zero, 0		# Set inAir = 0 (not in air)
	j jumpLookKey			# Return to main
	
restartGame:
	# For now, this function will prematurely exit
	# Later on, change this to restart the game
	#j END
	addi $s0, $s0, 1
	jal updateScore
	j jumpKeyPressed




#####---------------------------------COIN COLLISION FUNCTIONS--------------------------#####
# Check if coin was collected
# Store x1, x2 in $a0, $a1
# Store y1, y2 in $a2, $a3
checkCoin:
	addi $a1, $a0, 9			# Add 9 for the range of x
	addi $a3, $a2, 9			# Add 9 for the range of y
	bge $s1, $a0, xCoinCheck		# Check if x >= x1
	jr $ra
xCoinCheck:
	ble $s1, $a1, yCoinCheck		# Check if x <= x2
	jr $ra
yCoinCheck: 
	bge $s2, $a2, yCoinCheck2	# Check if y <= y1
	jr $ra	
yCoinCheck2:
	ble $s2, $a3, updateCoin		# Check if y >= y2
	jr $ra 
	

# Erase coin and update score
updateCoin:
	addi $t2, $a0, 3			# Add 3 to x and store in temp register
	addi $t3, $a2, 3			# Add 3 to y and store in temp register
	move $a2, $t2			# Store arguments
	move $a3, $t3			# Store arguments
	
	addi $s0, $s0, 1			# Increment score by 1 (100)
	jal eraseCoin			# Call function and remove coin
	jal updateScore			# Call function and update score
	j skipCoinChecks
	

# Erase previous score and update with new one	
updateScore:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	jal eraseScore		
	addi $t1, $zero, 1 		# Store all the different score values
	addi $t2, $zero, 2
	addi $t3, $zero, 3
	addi $t4, $zero, 4 	
	addi $t5, $zero, 5 	
	addi $t6, $zero, 6
	addi $t7, $zero, 7
	
	beq $s0, $t1, drawNum1		# Check what the score is 
	beq $s0, $t2, drawNum2
	beq $s0, $t3, drawNum3
	beq $s0, $t4, drawNum4
	beq $s0, $t5, drawNum5
	beq $s0, $t6, drawNum6
	beq $s0, $t7, drawNum7
	
jumpUpdateScore:				# Jump back from the draw num functions
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra				# Jump back to line that called us


# Function that erases score
eraseScore:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	# Row 1
	li $a0, BLACK			# $a0 stores the white colour code
	addi $a1, $zero, 41		# $a1 stores start index
	addi $a2, $zero, 44		# $a2 stores length
	addi $a3, $zero, 58		# $a3 stores y-value		
	jal drawLine
	# Row 2
	addi $a1, $zero, 41		# $a1 stores start index
	addi $a2, $zero, 44		# $a2 stores length
	addi $a3, $zero, 59		# $a3 stores y-value		
	jal drawLine
	# Row 3
	addi $a1, $zero, 41		# $a1 stores start index
	addi $a2, $zero, 44		# $a2 stores length
	addi $a3, $zero, 60		# $a3 stores y-value		
	jal drawLine
	# Row 4
	addi $a1, $zero, 41		# $a1 stores start index
	addi $a2, $zero, 44		# $a2 stores length
	addi $a3, $zero, 61		# $a3 stores y-value		
	jal drawLine
	# Row 5
	addi $a1, $zero, 41		# $a1 stores start index
	addi $a2, $zero, 44		# $a2 stores length
	addi $a3, $zero, 62		# $a3 stores y-value		
	jal drawLine
	
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra				# Jump back to line that called us
	
	
# Draw score value functions
drawNum1:
	li $t1, WHITE			# Load white
	sw $t1, 15020($t0)		# Paint pixel
	sw $t1, 15272($t0)		# Paint pixel
	sw $t1, 15276($t0)		# Paint pixel
	sw $t1, 15532($t0)		# Paint pixel
	sw $t1, 15788($t0)		# Paint pixel
	sw $t1, 16044($t0)		# Paint pixel
	sw $t1, 16040($t0)		# Paint pixel
	sw $t1, 16048($t0)		# Paint pixel
	j jumpUpdateScore
	
drawNum2:
	li $t1, WHITE			# Load white
	sw $t1, 15016($t0)		# Paint pixel
	sw $t1, 15020($t0)		# Paint pixel
	sw $t1, 15268($t0)		# Paint pixel
	sw $t1, 15280($t0)		# Paint pixel
	sw $t1, 15532($t0)		# Paint pixel
	sw $t1, 15784($t0)		# Paint pixel
	sw $t1, 16036($t0)		# Paint pixel
	sw $t1, 16040($t0)		# Paint pixel
	sw $t1, 16044($t0)		# Paint pixel
	sw $t1, 16048($t0)		# Paint pixel
	j jumpUpdateScore

drawNum3:
	li $t1, WHITE			# Load white
	sw $t1, 15016($t0)		# Paint pixel
	sw $t1, 15020($t0)		# Paint pixel
	sw $t1, 15268($t0)		# Paint pixel
	sw $t1, 15280($t0)		# Paint pixel
	sw $t1, 15532($t0)		# Paint pixel
	sw $t1, 15792($t0)		# Paint pixel
	sw $t1, 15780($t0)		# Paint pixel
	sw $t1, 16040($t0)		# Paint pixel
	sw $t1, 16044($t0)		# Paint pixel
	j jumpUpdateScore

drawNum4:
	li $t1, WHITE			# Load white
	sw $t1, 15012($t0)		# Paint pixel
	sw $t1, 15268($t0)		# Paint pixel
	sw $t1, 15528($t0)		# Paint pixel
	sw $t1, 15532($t0)		# Paint pixel
	sw $t1, 15024($t0)		# Paint pixel
	sw $t1, 15280($t0)		# Paint pixel
	sw $t1, 15536($t0)		# Paint pixel
	sw $t1, 15792($t0)		# Paint pixel
	sw $t1, 16048($t0)		# Paint pixel
	j jumpUpdateScore

drawNum5:
	li $t1, WHITE			# Load white
	sw $t1, 15016($t0)		# Paint pixel
	sw $t1, 15020($t0)		# Paint pixel
	sw $t1, 15024($t0)		# Paint pixel
	sw $t1, 15272($t0)		# Paint pixel
	sw $t1, 15528($t0)		# Paint pixel
	sw $t1, 15532($t0)		# Paint pixel
	sw $t1, 15536($t0)		# Paint pixel
	sw $t1, 15792($t0)		# Paint pixel
	sw $t1, 16044($t0)		# Paint pixel
	sw $t1, 16040($t0)		# Paint pixel
	j jumpUpdateScore
	
drawNum6:
	li $t1, WHITE			# Load white
	sw $t1, 15016($t0)		# Paint pixel
	sw $t1, 15020($t0)		# Paint pixel
	sw $t1, 15268($t0)		# Paint pixel
	sw $t1, 15524($t0)		# Paint pixel
	sw $t1, 15528($t0)		# Paint pixel
	sw $t1, 15532($t0)		# Paint pixel
	sw $t1, 15780($t0)		# Paint pixel
	sw $t1, 15792($t0)		# Paint pixel
	sw $t1, 16040($t0)		# Paint pixel
	sw $t1, 16044($t0)		# Paint pixel
	j jumpUpdateScore

drawNum7:
	li $t1, WHITE			# Load white
	sw $t1, 15012($t0)		# Paint pixel
	sw $t1, 15016($t0)		# Paint pixel
	sw $t1, 15020($t0)		# Paint pixel
	sw $t1, 15280($t0)		# Paint pixel
	sw $t1, 15532($t0)		# Paint pixel
	sw $t1, 15784($t0)		# Paint pixel
	sw $t1, 16040($t0)		# Paint pixel
	j jumpUpdateScore





#####-------------------------------------DRAW BOARD----------------------------------#####

drawStart:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	#---------------------------------Draw Water---------------------------------------
	# Draw water line 1
	li $a0, WATERBLUE		# $a0 stores the white colour code
	addi $a3, $zero, waterLine1	# $a3 stores y-value
	addi $a1, $zero, 0		# $a1 stores start index
	addi $a2, $zero, 63		# $a2 stores length		
	jal drawLine
	# Draw water line 2
	li $a0, WATERBLUE		# $a0 stores the white colour code
	addi $a3, $zero, waterLine2	# $a3 stores y-value
	addi $a1, $zero, 0		# $a1 stores start index
	addi $a2, $zero, 63		# $a2 stores length		
	jal drawLine
	
	
	#---------------------------------Draw Score---------------------------------------
	# Draw white line for score
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, scoreLineY	# $a3 stores y-value
	addi $a1, $zero, 0		# $a1 stores start index
	addi $a2, $zero, 63		# $a2 stores end index
	jal drawLine
	# Draw 5 Lines for Score Text
	# Draw white line for score
	# Line 1
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 58		# $a3 stores y-value
	addi $a1, $zero, 10		# $a1 stores start index
	addi $a2, $zero, 33		# $a2 stores end index
	jal drawLine
	# Line 2
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 59		# $a3 stores y-value
	addi $a1, $zero, 10		# $a1 stores start index
	addi $a2, $zero, 33		# $a2 stores end index
	jal drawLine
	# Line 3
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 60		# $a3 stores y-value
	addi $a1, $zero, 10		# $a1 stores start index
	addi $a2, $zero, 33		# $a2 stores end index
	jal drawLine
	# Line 4
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 61		# $a3 stores y-value
	addi $a1, $zero, 10		# $a1 stores start index
	addi $a2, $zero, 33		# $a2 stores end index
	jal drawLine
	# Line 5
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 62		# $a3 stores y-value
	addi $a1, $zero, 10		# $a1 stores start index
	addi $a2, $zero, 33		# $a2 stores end index
	jal drawLine
	# Chiesel Details
	# First Row
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 58 		# $a3 stores y-value
	addi $a1, $zero, 10		# $a1 stores start index
	addi $a2, $zero, 10		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 58 		# $a3 stores y-value
	addi $a1, $zero, 14		# $a1 stores start index
	addi $a2, $zero, 15		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 58 		# $a3 stores y-value
	addi $a1, $zero, 19		# $a1 stores start index
	addi $a2, $zero, 20		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 58 		# $a3 stores y-value
	addi $a1, $zero, 23		# $a1 stores start index
	addi $a2, $zero, 24		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 58 		# $a3 stores y-value
	addi $a1, $zero, 28		# $a1 stores start index
	addi $a2, $zero, 30		# $a2 stores end index
	jal drawLine
	# Second Row
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 59 		# $a3 stores y-value
	addi $a1, $zero, 11		# $a1 stores start index
	addi $a2, $zero, 14		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 59 		# $a3 stores y-value
	addi $a1, $zero, 16		# $a1 stores start index
	addi $a2, $zero, 19		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 59 		# $a3 stores y-value
	addi $a1, $zero, 21		# $a1 stores start index
	addi $a2, $zero, 22		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 59 		# $a3 stores y-value
	addi $a1, $zero, 24		# $a1 stores start index
	addi $a2, $zero, 24		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 59 		# $a3 stores y-value
	addi $a1, $zero, 26		# $a1 stores start index
	addi $a2, $zero, 27		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 59 		# $a3 stores y-value
	addi $a1, $zero, 29		# $a1 stores start index
	addi $a2, $zero, 29		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 59 		# $a3 stores y-value
	addi $a1, $zero, 31		# $a1 stores start index
	addi $a2, $zero, 33		# $a2 stores end index
	jal drawLine
	# Third Row
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 60 		# $a3 stores y-value
	addi $a1, $zero, 14		# $a1 stores start index
	addi $a2, $zero, 14		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 60 		# $a3 stores y-value
	addi $a1, $zero, 16		# $a1 stores start index
	addi $a2, $zero, 19		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 60 		# $a3 stores y-value
	addi $a1, $zero, 21		# $a1 stores start index
	addi $a2, $zero, 22		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 60 		# $a3 stores y-value
	addi $a1, $zero, 24		# $a1 stores start index
	addi $a2, $zero, 24		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 60 		# $a3 stores y-value
	addi $a1, $zero, 28		# $a1 stores start index
	addi $a2, $zero, 29		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 60 		# $a3 stores y-value
	addi $a1, $zero, 33		# $a1 stores start index
	addi $a2, $zero, 33		# $a2 stores end index
	jal drawLine
	# Fourth Row
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 61 		# $a3 stores y-value
	addi $a1, $zero, 10		# $a1 stores start index
	addi $a2, $zero, 12		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 61 		# $a3 stores y-value
	addi $a1, $zero, 14		# $a1 stores start index
	addi $a2, $zero, 14		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 61 		# $a3 stores y-value
	addi $a1, $zero, 16		# $a1 stores start index
	addi $a2, $zero, 19		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 61 		# $a3 stores y-value
	addi $a1, $zero, 21		# $a1 stores start index
	addi $a2, $zero, 22		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 61 		# $a3 stores y-value
	addi $a1, $zero, 24		# $a1 stores start index
	addi $a2, $zero, 24		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 61 		# $a3 stores y-value
	addi $a1, $zero, 26		# $a1 stores start index
	addi $a2, $zero, 26		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 61 		# $a3 stores y-value
	addi $a1, $zero, 28		# $a1 stores start index
	addi $a2, $zero, 29		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 61 		# $a3 stores y-value
	addi $a1, $zero, 31		# $a1 stores start index
	addi $a2, $zero, 33		# $a2 stores end index
	jal drawLine
	# Fifth Row
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 62 		# $a3 stores y-value
	addi $a1, $zero, 13		# $a1 stores start index
	addi $a2, $zero, 15		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 62 		# $a3 stores y-value
	addi $a1, $zero, 19		# $a1 stores start index
	addi $a2, $zero, 20		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 62 		# $a3 stores y-value
	addi $a1, $zero, 23		# $a1 stores start index
	addi $a2, $zero, 24		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 62 		# $a3 stores y-value
	addi $a1, $zero, 26		# $a1 stores start index
	addi $a2, $zero, 27		# $a2 stores end index
	jal drawLine
	li $a0, BLACK			# $a0 stores the black colour code
	addi $a3, $zero, 62 		# $a3 stores y-value
	addi $a1, $zero, 29		# $a1 stores start index
	addi $a2, $zero, 30		# $a2 stores end index
	jal drawLine
	# Draw Colons
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 59 		# $a3 stores y-value
	addi $a1, $zero, 36		# $a1 stores start index
	addi $a2, $zero, 36		# $a2 stores end index
	jal drawLine
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 61 		# $a3 stores y-value
	addi $a1, $zero, 36		# $a1 stores start index
	addi $a2, $zero, 36		# $a2 stores end index
	jal drawLine
	
	
	#---------------------------------Draw Score Numbers-------------------------------
	# Draw Zeroes
	# Row 1
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 58 		# $a3 stores y-value
	addi $a1, $zero, 42		# $a1 stores start index
	addi $a2, $zero, 43		# $a2 stores end index
	jal drawLine
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 58 		# $a3 stores y-value
	addi $a1, $zero, 47		# $a1 stores start index
	addi $a2, $zero, 48		# $a2 stores end index
	jal drawLine
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 58 		# $a3 stores y-value
	addi $a1, $zero, 52		# $a1 stores start index
	addi $a2, $zero, 53		# $a2 stores end index
	jal drawLine
	# Row 2
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 62 		# $a3 stores y-value
	addi $a1, $zero, 42		# $a1 stores start index
	addi $a2, $zero, 43		# $a2 stores end index
	jal drawLine
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 62 		# $a3 stores y-value
	addi $a1, $zero, 47		# $a1 stores start index
	addi $a2, $zero, 48		# $a2 stores end index
	jal drawLine
	li $a0, WHITE			# $a0 stores the white colour code
	addi $a3, $zero, 62 		# $a3 stores y-value
	addi $a1, $zero, 52		# $a1 stores start index
	addi $a2, $zero, 53		# $a2 stores end index
	jal drawLine
	li $a0, WHITE			# $a0 stores the white colour code
	# Coloumn 1
	sw $a0, 15268($t0)		# Paint pixel white
	sw $a0, 15524($t0)		# Paint pixel white
	sw $a0, 15780($t0)		# Paint pixel white
	# Coloumn 2
	sw $a0, 15280($t0)		# Paint pixel white
	sw $a0, 15536($t0)		# Paint pixel white
	sw $a0, 15792($t0)		# Paint pixel white
	# Coloumn 3
	sw $a0, 15288($t0)		# Paint pixel white
	sw $a0, 15544($t0)		# Paint pixel white
	sw $a0, 15800($t0)		# Paint pixel white
	# Coloumn 4
	sw $a0, 15300($t0)		# Paint pixel white
	sw $a0, 15556($t0)		# Paint pixel white
	sw $a0, 15812($t0)		# Paint pixel white
	# Coloumn 5
	sw $a0, 15308($t0)		# Paint pixel white
	sw $a0, 15564($t0)		# Paint pixel white
	sw $a0, 15820($t0)		# Paint pixel white
	# Coloumn 6
	sw $a0, 15320($t0)		# Paint pixel white
	sw $a0, 15576($t0)		# Paint pixel white
	sw $a0, 15832($t0)		# Paint pixel white
		
		
	#---------------------------------Draw Static Platforms----------------------------
	# Platforms are numbered from bottom to top, left to right
	# Platform 1 (starting platform)
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 49 		# $a3 stores y-value
	addi $a1, $zero, 0		# $a1 stores start index
	addi $a2, $zero, 9		# $a2 stores end index
	jal drawLine
	# Platform 2
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 45 		# $a3 stores y-value
	addi $a1, $zero, 19		# $a1 stores start index
	addi $a2, $zero, 27		# $a2 stores end index
	jal drawLine
	# Platform 3
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 40 		# $a3 stores y-value
	addi $a1, $zero, 33		# $a1 stores start index
	addi $a2, $zero, 42		# $a2 stores end index
	jal drawLine
	# Platform 4
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 40 		# $a3 stores y-value
	addi $a1, $zero, 59		# $a1 stores start index
	addi $a2, $zero, 63		# $a2 stores end index
	jal drawLine
	# Platform 5
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 33 		# $a3 stores y-value
	addi $a1, $zero, 21		# $a1 stores start index
	addi $a2, $zero, 27		# $a2 stores end index
	jal drawLine
	# Platform 7
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 27 		# $a3 stores y-value
	addi $a1, $zero, 7		# $a1 stores start index
	addi $a2, $zero, 15		# $a2 stores end index
	jal drawLine
	# Platform 8
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 27 		# $a3 stores y-value
	addi $a1, $zero, 59		# $a1 stores start index
	addi $a2, $zero, 63		# $a2 stores end index
	jal drawLine
	# Platform 9
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 21 		# $a3 stores y-value
	addi $a1, $zero, 0		# $a1 stores start index
	addi $a2, $zero, 3		# $a2 stores end index
	jal drawLine
	# Platform 11
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 17 		# $a3 stores y-value
	addi $a1, $zero, 25		# $a1 stores start index
	addi $a2, $zero, 35		# $a2 stores end index
	jal drawLine
	# Platform 13
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 6 		# $a3 stores y-value
	addi $a1, $zero, 0		# $a1 stores start index
	addi $a2, $zero, 8		# $a2 stores end index
	jal drawLine
	# Platform 14
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 6 		# $a3 stores y-value
	addi $a1, $zero, 59		# $a1 stores start index
	addi $a2, $zero, 63		# $a2 stores end index
	jal drawLine
		
	
	#---------------------------------Draw Button--------------------------------------
	# Button Base
	li $a0, BUTTONGRAY		# $a0 stores the colour code
	addi $a3, $zero, 5 		# $a3 stores y-value
	addi $a1, $zero, 1		# $a1 stores start index
	addi $a2, $zero, 6		# $a2 stores end index
	jal drawLine
	# Button
	li $a0, BUTTONRED		# $a0 stores the colour code
	addi $a3, $zero, 4 		# $a3 stores y-value
	addi $a1, $zero, 2		# $a1 stores start index
	addi $a2, $zero, 5		# $a2 stores end index
	jal drawLine
	# Barrier
	li $a0, BARRIERBROWN		# $a0 stores the colour code
	sw $a0, 32($t0)			# Paint colour
	sw $a0, 288($t0)			# Paint colour
	sw $a0, 544($t0)			# Paint colour
	sw $a0, 800($t0)			# Paint colour
	sw $a0, 1056($t0)		# Paint colour
	sw $a0, 1312($t0)		# Paint colour


	#---------------------------------Draw Stopped Platforms---------------------------
	# Platform 6
	li $a0, STOPPEDORANGE		# $a0 stores the colour code
	addi $a3, $zero, 33 		# $a3 stores y-value
	addi $a1, $zero, 47		# $a1 stores start index
	addi $a2, $zero, 53		# $a2 stores end index
	jal drawLine
	# Platform 10
	li $a0, STOPPEDORANGE		# $a0 stores the colour code
	addi $a3, $zero, 17 		# $a3 stores y-value
	addi $a1, $zero, 10		# $a1 stores start index
	addi $a2, $zero, 16		# $a2 stores end index
	jal drawLine
	# Platform 12
	li $a0, STOPPEDORANGE		# $a0 stores the colour code
	addi $a3, $zero, 11 		# $a3 stores y-value
	addi $a1, $zero, 42		# $a1 stores start index
	addi $a2, $zero, 51		# $a2 stores end index
	jal drawLine
	
	
	#---------------------------------Draw Coins---------------------------------------
	# Coins are numbered from lowest to highest, left to right
	
	# Coin 1
	addi $a2, $zero, 12		# Set x value
	addi $a3, $zero, 41		# Set y value
	jal drawCoin
	# Coin 2
	addi $a2, $zero, 35		# Set x value
	addi $a3, $zero, 26		# Set y value
	jal drawCoin
	# Coin 3
	addi $a2, $zero, 45		# Set x value
	addi $a3, $zero, 6		# Set y value
	jal drawCoin
	
	
	#---------------------------------Draw Pickups-------------------------------------
	# Blue Pickup
	li $a0, PPBLUE1
	addi $a1, $zero, 60
	addi $a2, $zero, 62
	addi $a3, $zero, 36
	jal drawPickup
	# Green Pickup
	li $a0, PPGREEN1
	addi $a1, $zero, 29
	addi $a2, $zero, 31
	addi $a3, $zero, 13
	jal drawPickup
	# Purple Pickup 
	li $a0, PPVIOLET1
	addi $a1, $zero, 60
	addi $a2, $zero, 62
	addi $a3, $zero, 2
	jal drawPickup

	
	#---------------------------------Draw Character----------------------------------
	addi $a1, $zero, 2		# Set x-value
	addi $a3, $zero, 46		# Set y-value
	jal drawCharacter
	
	
	# Finish Drawing Board
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	





#####-------------------------------------DRAWING FUNCTIONS---------------------------#####

#-----------------------------------------Draw Line Function-------------------------------
# This function draws a horizontal line given the dimensions
# let $t0 = base_address
# let $t1 = colour code
# let $t2 = i
# let $t3 = end index 
# let $t4 = y * width
# let $t5 = address of pixel
# let $t6 = address of pixel + base address
drawLine:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	move $t1, $a0			# Get arguments
	move $t2, $a1
	move $t3, $a2
	move $t4, $a3
	
	sll $t2, $t2, 2			# $t2 = start index * 4
	sll $t3, $t3, 2			# Set $t3 = end index * 4
	sll $t4, $t4, 8			# Multiply y value by 256 to get y*width*4
drawLineLoop:
	add $t5, $t4, $t2		# $t5 = y*width + x		
	add $t6, $t5, $t0		# $t6 = address of pixel + base address
	sw $t1, 0($t6)			# Paint the pixel
	addi $t2, $t2, 4			# Increment index by 4
	ble $t2, $t3, drawLineLoop	# Continue loop if i <= end index
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra				# Jump back to line that called us
	
	

#-----------------------------------------Draw Coin Function-------------------------------	
drawCoin:
# $t0 = base address
# $t1 = colour code
# $t2 = x coordinate
# $t3 = y coordinate
# $t4 = address of pixel
# $t5 = base address + index
# $t6 = temp storage for address

	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	move $t2, $a2			# $t2 gets x-value
	move $t3, $a3			# $t3 gets y-value
	
	# Row 1
	li $t1, COINYELLOW		# Load colour into $t1
	sll $t6, $t3, 8			# $t6 = y*256	
	sll $t4, $t2, 2			# $t4 = x*4
	add $t4, $t4, $t6		# $t4 = address of pixel
	
	addi $t6, $t4, 4			# Update index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel	
	addi $t6, $t6, 4			# Update index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	
	# Row 2
	addi $t6, $t4, 256		# Update y index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel	
	li $t1, WHITE			# Change colour
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	li $t1, COINBLUE			# Change colour
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	li $t1, COINYELLOW		# Change colour
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	
	# Row 3
	addi $t6, $t4, 512		# Update y index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	li $t1, COINBLUE			# Change colour
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	li $t1, COINYELLOW		# Change colour
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	
	# Row 4
	addi $t6, $t4, 768		# Update y index
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
		
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	
	
	
eraseCoin:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	move $t2, $a2			# $t2 gets x-value
	move $t3, $a3			# $t3 gets y-value
	
	# Row 1
	li $t1, BLACK			# Load colour into $t1
	sll $t6, $t3, 8			# $t6 = y*256	
	sll $t4, $t2, 2			# $t4 = x*4
	add $t4, $t4, $t6		# $t4 = address of pixel
	
	addi $t6, $t4, 4			# Update index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel	
	addi $t6, $t6, 4			# Update index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	
	# Row 2
	addi $t6, $t4, 256		# Update y index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel	
	li $t1, BLACK			# Change colour
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	li $t1, BLACK			# Change colour
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	li $t1, BLACK			# Change colour
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	
	# Row 3
	addi $t6, $t4, 512		# Update y index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	li $t1, BLACK			# Change colour
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	li $t1, BLACK			# Change colour
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	
	# Row 4
	addi $t6, $t4, 768		# Update y index
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
	addi $t6, $t6, 4			# Update x index
	add $t5, $t6, $t0		# $t5 = base address + index 
	sw $t1, 0($t5)			# Paint pixel
		
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	
	
	
	
	
				
#-----------------------------------------Draw Pickup Function-----------------------------					
drawPickup:
# $a0 = determines which colour pickup to draw ( PPBLUE1 = blue, PPGREEN1 = green, PPVIOLET1 = purple )
# $a1 = start index
# $a2 = end index
# $a3 = y value
	
	# Store $ra
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	move $t7, $a1			# Store arguments in temp registers
	move $t8, $a2
	move $t9, $a3	
	
	beq $a0, PPBLUE1, drawPickupBlue	# Check which colour pickup to draw
	beq $a0, PPGREEN1, drawPickupGreen
drawPickupPurple:
	li $a0, PPVIOLET1		# $a0 stores the colour code
	add $a3, $zero, $t9 		# $a3 stores y-value
	add $a1, $zero, $t7		# $a1 stores start index
	add $a2, $zero, $t8		# $a2 stores end index
	jal drawLine
	li $a0, PPVIOLET2		# $a0 stores the colour code
	add $a3, $zero, $t9 		# $a3 stores y-value
	addi $a3, $a3, 1			# Go down one level
	add $a1, $zero, $t7		# $a1 stores start index
	add $a2, $zero, $t8		# $a2 stores end index
	jal drawLine
	li $a0, WHITE			# $a0 stores the colour code
	add $a3, $zero, $t9 		# $a3 stores y-value
	addi $a3, $a3, 2			# Go down one level
	add $a1, $zero, $t7		# $a1 stores start index
	add $a2, $zero, $t8		# $a2 stores end index
	jal drawLine
	j drawPickupEND
drawPickupBlue:	
	li $a0, PPBLUE1			# $a0 stores the colour code
	add $a3, $zero, $t9 		# $a3 stores y-value
	add $a1, $zero, $t7		# $a1 stores start index
	add $a2, $zero, $t8		# $a2 stores end index
	jal drawLine
	li $a0, PPBLUE2			# $a0 stores the colour code
	add $a3, $zero, $t9 		# $a3 stores y-value
	addi $a3, $a3, 1			# Go down one level
	add $a1, $zero, $t7		# $a1 stores start index
	add $a2, $zero, $t8		# $a2 stores end index
	jal drawLine
	li $a0, WHITE			# $a0 stores the colour code
	add $a3, $zero, $t9 		# $a3 stores y-value
	addi $a3, $a3, 2			# Go down one level
	add $a1, $zero, $t7		# $a1 stores start index
	add $a2, $zero, $t8		# $a2 stores end index
	jal drawLine
	j drawPickupEND
drawPickupGreen:
	li $a0, PPGREEN1			# $a0 stores the colour code
	add $a3, $zero, $t9 		# $a3 stores y-value
	add $a1, $zero, $t7		# $a1 stores start index
	add $a2, $zero, $t8		# $a2 stores end index
	jal drawLine
	li $a0, PPGREEN2			# $a0 stores the colour code
	add $a3, $zero, $t9 		# $a3 stores y-value
	addi $a3, $a3, 1			# Go down one level
	add $a1, $zero, $t7		# $a1 stores start index
	add $a2, $zero, $t8		# $a2 stores end index
	jal drawLine
	li $a0, WHITE			# $a0 stores the colour code
	add $a3, $zero, $t9 		# $a3 stores y-value
	addi $a3, $a3, 2			# Go down one level
	add $a1, $zero, $t7		# $a1 stores start index
	add $a2, $zero, $t8		# $a2 stores end index
	jal drawLine
	j drawPickupEND	
drawPickupEND:	
	lw $ra, 0($sp)		# Restore $ra
	addi $sp, $sp, 4		# Prepare stack address
	jr $ra	
	

				
						
#-----------------------------------------Draw Character Function-------------------------
# $a1 = x value
# $a3 = y value

drawCharacter:
	# Store $ra
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	addi $a2, $a1, 2 		# Create and store the end index
	move $t7, $a1			# Store start index
	move $t8, $a2			# Store end index
	move $t9, $a3			# Store y-value
	# Draw Hair
	li $a0, HAIRWHITE		# Load colour
	jal drawLine
	# Draw Face
	li $a0, SKINPEACH
	move $a1, $t7			# Restore x-value
	move $a2, $t8			# Resore end index
	addi $a3, $t9, 2			# Update y index
	jal drawLine
	# Draw Eyes and Nose
	li $t1, LEFTEYE
	sll $t2, $t9, 8			# $t2 = y*256 
	sll $t3, $t7, 2			# $t3 = x*4
	add $t2, $t2, $t3		# $t2 = address of pixel
	addi $t2, $t2, 256		# Go down one level
	add $t5, $t2, $t0		# $t5 = base address + pixel index
	sw $t1, 0($t5)			# Paint pixel		
	li $t1, SKINPEACH
	addi $t2, $t2, 4			# Go right one x unit
	add $t5, $t2, $t0		# $t5 = base address + pixel index
	sw $t1, 0($t5)			# Paint pixel	
	li $t1, RIGHTEYE
	addi $t2, $t2, 4			# Go right one x unit
	add $t5, $t2, $t0		# $t5 = base address + pixel index
	sw $t1, 0($t5)			# Paint pixel	
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	

#-----------------------------------------Erase Character Function------------------------
# $a1 = x value
# $a3 = y value

eraseCharacter:
	# Store $ra
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	addi $a2, $a1, 2 		# Create and store the end index
	move $t7, $a1			# Store start index
	move $t8, $a2			# Store end index
	# Erase Hair
	li $a0, BLACK			# Load colour
	jal drawLine
	# Erase Eyes and Nose
	move $a1, $t7			# Restore x-value
	move $a2, $t8			# Resore end index
	addi $a3, $a3, 1			# Update y index
	jal drawLine
	# Erase Face
	move $a1, $t7			# Restore x-value
	move $a2, $t8			# Resore end index
	addi $a3, $a3, 1			# Update y index
	jal drawLine
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	
	
	





	
		
																																															
																																																				
																																																								
																																																												
																																																																				
	
#----------------------------------------Other Functions-------------------------------		
	
clearRegisters:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack

	move $t1, $0			# Clear register
	move $t2, $0			# Clear register
	move $t3, $0			# Clear register
	move $t4, $0			# Clear register
	move $t5, $0			# Clear register
	move $t6, $0			# Clear register
	move $t7, $0			# Clear register
	move $t8, $0			# Clear register
	move $t9, $0			# Clear register
	
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	

	
	







