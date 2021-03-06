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
# - Milestone 3
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Health/Score
# 2. Fail Condition
# 3. Win Condition
# 4. Moving Objects
# 5. Disappearing Platforms
# 6. Pick-up Effects
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - Share video but not GitHub repo
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
.eqv 	WINGREEN 0x17d421
.eqv	LOSERED	0xe91e62

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
.eqv	waitDelay 50
.eqv 	maxJumpCount 12

.data
# Array A = {oldx, oldy, plat6count, plat10count, bluecheck, greencheck, violetcheck}
A: 	.word 	2, 46, -1, -1, 1, 1, 1 	
# Array B = {plat6x, plat6y, plat10x, plat10y, bluex, bluey, blueoldx, blueoldy, greenx, greeny, greenoldx, greenoldy}	
B: 	.word 	2, 46, 0, 0, 60, 36, 60, 36, 29, 13, 29, 13
.text

#---------------------------------Initialize Game--------------------------------
initialize:
	addi $s0, $zero, 0		# Store player score
	addi $s1, $zero, 2		# Store player x-value
	addi $s2, $zero, 46		# Store player y-value
	la   $s3, A			# Store array A into $s3
	la   $s4, B 			# Store array B into $s4
	addi $s5, $zero, 0		# Store player jump counter
	addi $s6, $zero, 0		# Store inAir value (0 = not mid-jump, 1 = mid-jump)
	addi $s7, $zero, 0		# Store drawCheck (0 = draw, 1 = don't draw character)
	li $t0, BASE_ADDRESS		# $t0 stores the base address for display	
	jal drawStart			# Draw the screen
	
	
#---------------------------------Main Loop--------------------------------------
main:	
	# Set initial values
	addi $s7, $zero, 1		# Set drawCheck to 1 ( don't draw)
	sw $s1, 0($s3)			# Save old x value
	sw $s2, 4($s3)			# Save old y value
	lw $t1, 16($s4)			# Get new blue x
	lw $t2, 20($s4)			# Get new blue y
	sw $t1, 24($s4)			# Set old blue x to new blue x
	sw $t2, 28($s4)			# Set old blue x to new blue x
	lw $t1, 32($s4)			# Get new green x
	lw $t2, 36($s4)			# Get new greem y
	sw $t1, 40($s4)			# Set old green x to new green x
	sw $t2, 44($s4)			# Set old green x to new green x
	lw $t1, 8($s3)			# Load platform 6 count
	addi $t1, $t1, 1			# Increment by 1
	sw $t1, 8($s3)			# Store platform 6 count
	lw $t1, 12($s3)			# Load platform 10 count
	addi $t1, $t1, 1			# Increment by 1
	sw $t1, 12($s3)			# Store platform 10 count
	
	# Check for mid-jump/gravity
	beq $s6, $zero, moveGravity	# If not mid jump (inAir = 0), check gravity
	j altMoveUp			# Else, we are mid-jump so move up
				
jumpLookKey:	
	# Update disappearing platforms
checkPlat6:
	lw $t1, 8($s3)			# Load platform 6 count
	beqz $t1, drawPlatform6		# If count == 0, draw platform
	addi $t2, $zero, 20		# Set check
	beq $t1, $t2, erasePlatform6	# If count == mid point, erase the platform
	addi $t2, $zero, 40		# Set check
	beq $t1, $t2, updatePlatform6	# If count == end, draw platform and update count
checkPlat10:
	lw $t1, 12($s3)			# Load platform 10 count
	beqz $t1, drawPlatform10		# If count == 0, draw platform
	addi $t2, $zero, 20		# Set check
	beq $t1, $t2, erasePlatform10	# If count == mid point, erase the platform
	addi $t2, $zero, 40		# Set check
	beq $t1, $t2, updatePlatform10	# If count == end, draw platform and update count
	
skipPlatChecks:
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
	# Check for pickups
checkPPBlue:
	# Check for blue pickup
	lw $t1, 16($s3)			# Load bluecheck value into $t1
	beqz $t1, checkPPGreen		# If bluecheck = 0, skip checkPPBlue
	jal checkPickupBlue

checkPPGreen:
	# Check for green pickup
	lw $t1, 20($s3)			# Load greencheck value into $t1
	beqz $t1, checkPPViolet		# If greencheck = 0, skip checkPPGreen
	jal checkPickupGreen
	
checkPPViolet:
	# Check for violet pickup
	lw $t1, 24($s3)			# Load violetcheck value into $t1
	beqz $t1, skipPPChecks		# If violetcheck = 0, skip checkPPViolet
	jal checkPickupViolet
	
	
skipPPChecks:	
	# Hover pickups
checkBlueHover:
	# Hover blue
	lw $t1, 16($s3)			# Load bluecheck value into $t1
	beqz $t1, checkGreenHover	# If bluecheck = 0, skip checkBlueHover
	jal hoverBlue
checkGreenHover:
	# Hover green
	lw $t1, 20($s3)			# Load greencheck value into $t1
	beqz $t1, redrawCharacter	# If greencheck = 0, skip checkGreenHover
	jal hoverGreen
	
skipHoverChecks:

redrawCharacter:
	# Redraw Character
	addi $t5, $zero, 1		
	beq $s7, $t5, noUpdate		# If drawCheck == 1, skip updateCharacte

	# Erase object with old coordinates
	lw $a1, 0($s3)			# Get old x coordinate of character from array
	lw $a3, 4($s3)			# Get old y coordinate of character from array
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





#####------------------------------WIN/LOSE GAME FUNCTIONS-----------------------------#####

# Upon win of game, clear screen and print win game text
winGame:
	jal clearPartialScreen		# Partially clear screen
	li $a0, WINGREEN			# Load colour
	jal drawRestartText		# Draw restart text
	jal drawYou			# Draw the word "you"
	jal drawWin			# Draw the word "win"
	j endLoop
	
loseGame:
	jal clearPartialScreen		# Partially clear screen
	li $a0, LOSERED			# Load colour
	jal drawRestartText		# Draw restart text
	jal drawYou			# Draw the word "you"
	jal drawLose			# Draw the word "lose"
	j endLoop

# This loop is entered upon win/loss of game
endLoop:	
	# Check for key press
	li $t9, 0xffff0000		# Load keypressed memory address
	lw $t8, 0($t9)			
	bne $t8, 1, endLoop		# If key press didn't happen, continue loop
	lw $t2, 4($t9) 			# Else, Get key value of press
	beq $t2, 0x70, restartGame	# If "p" pressed, restart game
	j endLoop


#####---------------------------DISAPPEARING PLATFORMS FUNCTIONS-----------------------#####
# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra
# Update platform 6 functions
drawPlatform6:
	li $a0, BROWN			# $a0 stores the colour code
	addi $a1, $zero, 47		# $a1 stores start index
	addi $a2, $zero, 53		# $a2 stores end index
	addi $a3, $zero, 33 		# $a3 stores y-value
	jal drawLine
	j checkPlat10
erasePlatform6:
	li $a0, BLACK			# $a0 stores the colour code
	addi $a1, $zero, 47		# $a1 stores start index
	addi $a2, $zero, 53		# $a2 stores end index
	addi $a3, $zero, 33 		# $a3 stores y-value
	jal drawLine
	j checkPlat10
updatePlatform6:
	li $a0, BROWN			# $a0 stores the colour code
	addi $a1, $zero, 47		# $a1 stores start index
	addi $a2, $zero, 53		# $a2 stores end index
	addi $a3, $zero, 33 		# $a3 stores y-value
	jal drawLine
	sw $zero, 8($s3)			# Set count to 0
	j checkPlat10

# Update platform 10 functions
drawPlatform10:
	li $a0, BROWN			# $a0 stores the colour code
	addi $a1, $zero, 10		# $a1 stores start index
	addi $a2, $zero, 16		# $a2 stores end index
	addi $a3, $zero, 17 		# $a3 stores y-value
	jal drawLine
	j skipPlatChecks
erasePlatform10:
	li $a0, BLACK			# $a0 stores the colour code
	addi $a1, $zero, 10		# $a1 stores start index
	addi $a2, $zero, 16		# $a2 stores end index
	addi $a3, $zero, 17 		# $a3 stores y-value
	jal drawLine
	j skipPlatChecks
updatePlatform10:
	li $a0, BROWN			# $a0 stores the colour code
	addi $a1, $zero, 10		# $a1 stores start index
	addi $a2, $zero, 16		# $a2 stores end index
	addi $a3, $zero, 17 		# $a3 stores y-value
	jal drawLine
	sw $zero, 12($s3)		# Set count to 0
	j skipPlatChecks



#####---------------------------------PICKUP HOVER FUNCTIONS---------------------------#####

# This function will hover the blue pickup
hoverBlue:
	addi $t2, $zero, 1
	lw $t1, 16($s3)			# Load bluecheck value into $t1
	beq $t1, $t2, hoverBlueUp	# If bluecheck == 1, move up by 1
	# Else, move down by 1
	lw $t2, 20($s4)			# Get y value	
	addi $t2, $t2, 1			# Move y value down 1
	sw $t2, 20($s4)			# Save y value in array
	
	addi $t3, $zero, 36		# Set down boundary
	beq $t2, $t3, updateHoverBlueUp	# If y = boundary, update bluecheck to 1
	j updateBlue
	
hoverBlueUp:
	lw $t2, 20($s4)			# Get y value	
	addi $t2, $t2, -1		# Move y value up 1
	sw $t2, 20($s4)			# Save y value in array
	
	addi $t3, $zero, 33		# Set up boundary
	beq $t2, $t3, updateHoverBlueDown	# If y = boundary, update bluecheck to 2
	j updateBlue

updateHoverBlueUp:
	addi $t5, $zero, 1		# Set 1
	sw $t5, 16($s3)			# Set bluecheck to 1
	j updateBlue

updateHoverBlueDown:
	addi $t5, $zero, 2		# Set 2
	sw $t5, 16($s3)			# Set bluecheck to 2
	j updateBlue
	
updateBlue:
	# Erase pickup
	li $a0, PPBLUE1			# Load argument
	jal erasePickup
	# Redraw pickup
	li $a0, PPBLUE1
	lw $t1, 16($s4)			# Load new x value
	lw $t2, 20($s4)			# Load new y value
	move $a1, $t1			# Store start index
	addi $a2, $t1, 2			# Store end index
	move $a3, $t2			# Store y value
	jal drawPickup
	j checkGreenHover
	

# This function will hover the green pickup
hoverGreen:
	addi $t2, $zero, 1
	lw $t1, 20($s3)			# Load greencheck value into $t1
	beq $t1, $t2, hoverGreenUp	# If greencheck == 1, move up by 1
	# Else, move down by 1
	lw $t2, 36($s4)			# Get y value	
	addi $t2, $t2, 1			# Move y value down 1
	sw $t2, 36($s4)			# Save y value in array
	
	addi $t3, $zero, 13		# Set down boundary
	beq $t2, $t3, updateHoverGreenUp	# If y = boundary, update greencheck to 1
	j updateGreen

hoverGreenUp:
	lw $t2, 36($s4)			# Get y value	
	addi $t2, $t2, -1		# Move y value up 1
	sw $t2, 36($s4)			# Save y value in array
	
	addi $t3, $zero, 10		# Set up boundary
	beq $t2, $t3, updateHoverGreenDown	# If y = boundary, update greencheck to 2
	j updateGreen

updateHoverGreenUp:
	addi $t5, $zero, 1		# Set 1
	sw $t5, 20($s3)			# Set greencheck to 1
	j updateGreen

updateHoverGreenDown:
	addi $t5, $zero, 2		# Set 2
	sw $t5, 20($s3)			# Set bluecheck to 2
	j updateGreen

updateGreen:
	# Erase pickup
	li $a0, PPGREEN1			# Load argument
	jal erasePickup
	# Redraw pickup
	li $a0, PPGREEN1
	lw $t1, 32($s4)			# Load new x value
	lw $t2, 36($s4)			# Load new y value
	move $a1, $t1			# Store start index
	addi $a2, $t1, 2			# Store end index
	move $a3, $t2			# Store y value
	jal drawPickup
	j skipHoverChecks	
	


#####---------------------------------PICKUP COLLISION FUNCTIONS-----------------------#####
# Check if blue powerip was picked up
checkPickupBlue:
	addi $t1, $zero, 58		# Start x
	addi $t2, $zero, 63		# End x
	addi $t3, $zero, 31		# Start y
	addi $t4, $zero, 39		# End y
	bge $s1, $t1, xBlueCheck		# Check if x >= x1
	jr $ra
xBlueCheck:
	ble $s1, $t2, yBlueCheck		# Check if x <= x2
	jr $ra
yBlueCheck:
	bge $s2, $t3, yBlueCheck2	# Check if y <= y1
	jr $ra	
yBlueCheck2:
	ble $s2, $t4, activateBlue	# Check if y >= y2
	jr $ra 

# The blue pickup will turn water to wood
activateBlue:
	# Special Pickup Power
	# Turn water to wood by drawing over water lines with platform brown
	li $a0, BROWN			# $a0 stores the white colour code
	addi $a3, $zero, waterLine1	# $a3 stores y-value
	addi $a1, $zero, 0		# $a1 stores start index
	addi $a2, $zero, 63		# $a2 stores length		
	jal drawLine
	li $a0, BROWN			# $a0 stores the white colour code
	addi $a3, $zero, waterLine2	# $a3 stores y-value
	addi $a1, $zero, 0		# $a1 stores start index
	addi $a2, $zero, 63		# $a2 stores length		
	jal drawLine
	# Erase the pickup
	li $a0, PPBLUE1			# Load argument
	jal erasePickup
	# Set pickup check for blue to 0
	sw $zero, 16($s3)		# Set bluecheck to 0
	j skipPPChecks			# Return
	
	
# Check if green powerip was picked up
checkPickupGreen:
	addi $t1, $zero, 26		# Start x
	addi $t2, $zero, 34		# End x
	addi $t3, $zero, 8		# Start y
	addi $t4, $zero, 16		# End y
	bge $s1, $t1, xGreenCheck	# Check if x >= x1
	jr $ra
xGreenCheck:
	ble $s1, $t2, yGreenCheck	# Check if x <= x2
	jr $ra
yGreenCheck:
	bge $s2, $t3, yGreenCheck2	# Check if y <= y1
	jr $ra	
yGreenCheck2:
	ble $s2, $t4, activateGreen	# Check if y >= y2
	jr $ra 

# The green pickup will instantly give needed score to win (+300 score)
activateGreen:
	# Special Pickup Power
	# Increment score by 300
	addi $s0, $s0, 3			# Increment the score by 3 (300)
	jal updateScore
	# Erase the pickup
	li $a0, PPGREEN1			# Load argument
	jal erasePickup
	# Set pickup check for green to 0
	sw $zero, 20($s3)		# Set greencheck to 0
	j skipPPChecks			# Return
	

# Check if violet powerip was picked up
checkPickupViolet:
	addi $t1, $zero, 58		# Start x
	addi $t2, $zero, 63		# End x
	addi $t3, $zero, 0		# Start y
	addi $t4, $zero, 5		# End y
	bge $s1, $t1, xVioletCheck	# Check if x >= x1
	jr $ra
xVioletCheck:
	ble $s1, $t2, yVioletCheck	# Check if x <= x2
	jr $ra
yVioletCheck:
	bge $s2, $t3, yVioletCheck2	# Check if y <= y1
	jr $ra	
yVioletCheck2:
	ble $s2, $t4, activateViolet	# Check if y >= y2
	jr $ra 

# The violet pickup will unlock the barrier and create a path directly to the button
activateViolet:
	# Special Pickup Power
	# Remove barrier and draw path
	# Barrier 
	li $a0, BLACK			# $a0 stores the colour code
	sw $a0, 36($t0)			# Paint colour
	sw $a0, 292($t0)			# Paint colour
	sw $a0, 548($t0)			# Paint colour
	sw $a0, 804($t0)			# Paint colour
	sw $a0, 1060($t0)		# Paint colour
	sw $a0, 1316($t0)		# Paint colour
	# Path to button
	li $a0, BROWN			# Store colour code
	addi $a1, $zero, 10		# Start index
	addi $a2, $zero, 58		# End index
	addi $a3, $zero, 6		# y value
	jal drawLine
	# Erase the pickup
	li $a0, PPVIOLET1		# Load argument
	jal erasePickup
	# Set pickup check for violet to 0
	sw $zero, 24($s3)		# Set violetcheck to 0
	j skipPPChecks			# Return


# Erase the pickup based on colour inputted
erasePickup:
	# Store $ra
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	beq $a0, PPBLUE1, erasePickupBlue	# Check which colour pickup to draw
	beq $a0, PPGREEN1, erasePickupGreen
erasePickupViolet:
	addi $a1, $zero, 60		# Start x
	addi $a2, $zero, 62		# End x
	addi $a3, $zero, 2		# y value
	li $a0, BLACK			# $a0 stores the colour code
	jal drawLine
	addi $a3, $a3, 1			# Go down one level
	jal drawLine
	addi $a3, $a3, 1			# Go down one level
	jal drawLine
	j erasePickupEND
erasePickupBlue:
	lw $a1, 24($s4)			# Load old blue x value
	addi $a2, $a1, 2			# Load end index for x
	lw $a3, 28($s4)			# Load old blue y value
	li $a0, BLACK			# $a0 stores the colour code
	jal drawLine
	addi $a3, $a3, 1			# Go down one level
	jal drawLine
	addi $a3, $a3, 1			# Go down one level
	jal drawLine
	j erasePickupEND
erasePickupGreen:
	lw $a1, 40($s4)			# Load old x value
	addi $a2, $a1, 2			# Load end index for x
	lw $a3, 44($s4)			# Load old y value
	li $a0, BLACK			# $a0 stores the colour code
	jal drawLine
	addi $a3, $a3, 1			# Go down one level
	jal drawLine
	addi $a3, $a3, 1			# Go down one level
	jal drawLine
	j erasePickupEND

erasePickupEND:	
	lw $ra, 0($sp)		# Restore $ra
	addi $sp, $sp, 4		# Prepare stack address
	jr $ra	
	
	
	
	



#####---------------------------------MOVEMENT FUNCTIONS------------------------------#####
		
# Given colour, and x/y values, check if specified colour is under the player
checkBottom:
	move $t1, $a1			# Store colour
	move $t2, $a2			# Store x
	addi $t3, $a3, 3			# Store y
	
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
							
	sll $t4, $t3, 8			# Multiply y by 256
	sll $t2, $t2, 2			# Multiply x by 4
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
	addi $v0, $zero, 0		# Set $v0 to 0	
	ble $s1, $t5, jumpKeyPressed	# If x = 0, don't update x
	# Check for platform
	li $a1, BROWN			# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkLeft
	li $a1, BARRIERBROWN		# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkLeft
	li $a1, BUTTONGRAY		# Load colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkLeft
	li $a1, BUTTONRED		# Load colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkLeft
	# Else go left one
	addi $s7, $zero, 0		# Set drawCheck to 0
	bgtz $v0, jumpKeyPressed 	# If return greater than 0, don't go up
	addi $s1, $s1, -2		# Move x-value left 1
	j jumpKeyPressed
	
moveRight:
	addi $t5, $zero, 61		# Store right boundary
	addi $t6, $zero, 60		# Store right boundary
	addi $v0, $zero, 0		# Set $v0 to 0	
	beq $s1, $t6, altMoveRight	# Move right 1 if this exact x value
	bge $s1, $t5, jumpKeyPressed	# If x => 61, don't update x
	# Check for platform
	li $a1, BROWN			# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkRight
	# Else go right one
	addi $s7, $zero, 0		# Set drawCheck to 0
	bgtz $v0, jumpKeyPressed 	# If return greater than 0, don't go up
	addi $s1, $s1, 2			# Move x-value right 1
	j jumpKeyPressed
altMoveRight:
	addi $s7, $zero, 0		# Set drawCheck to 0
	addi $s1, $s1, 1			# Move x-value right 1
	j jumpKeyPressed
	
moveUp: 
	addi $v0, $zero, 0		# Set $v0 to 0
	addi $t6, $zero, maxJumpCount	# Store max jump counter
	beq $s5, $t6, lastMoveUp 	# If jump counter == maxJumpCount
	addi $t5, $zero, 0		# Store top boundary
	beq $s2, $t5, moveUpBoundary	# If y = 0, don't update y
	# Check for platform
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
	addi $v0, $zero, 0		# Set $v0 to 0
	addi $t5, $zero, 0		# Store top boundary
	beq $s2, $t5, moveUpBoundary	# If y = 0, don't update y
	# Check for platform
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
moveUpBoundary:
	addi $s5, $zero, 0		# Reset jump counter
	addi $s7, $zero, 0		# Set drawCheck to 0
	addi $s6, $zero, 0		# Set inAir to 0
	j jumpKeyPressed
# Alternate moveUp for the case where mid jump but you still need to check for key press	
altMoveUp: 
	addi $v0, $zero, 0		# Set $v0 to 0
	addi $t6, $zero,  maxJumpCount	# Store max jump counter
	beq $s5, $t6, altLastMoveUp 	# If jump counter == maxJumpCount
	addi $t5, $zero, 0		# Store top boundary
	beq $s2, $t5, altMoveUpBoundary	# If y = 0, don't update y
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
	addi $v0, $zero, 0		# Set $v0 to 0
	addi $t5, $zero, 0		# Store top boundary
	beq $s2, $t5, altMoveUpBoundary	# If y = 0, don't update y
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
altMoveUpBoundary:
	addi $s5, $zero, 0		# Reset jump counter
	addi $s7, $zero, 0		# Set drawCheck to 0
	addi $s6, $zero, 0		# Set inAir to 0
	j jumpLookKey
	
moveGravity: 
	# Check for on platform
	addi $v0, $zero, 0		# Set $v0 to 0
	li $a1, WATERBLUE		# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkBottom
	bgtz $v0, loseGame 		# If return greater than 0, water touched, so lose game
	addi $v0, $zero, 0		# Set $v0 to 0
	li $a1, BUTTONRED		# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkBottom
	li $a1, BUTTONGRAY		# Load platform colour
	move $a2, $s1			# Set $a2 to new x
	move $a3, $s2			# Set $a3 to new y
	jal checkBottom
	bgtz $v0, winGame 		# If return greater than 0, button touched, so win game
	addi $v0, $zero, 0		# Set $v0 to 0
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
	jal clearScreen
	jal clearRegisters
	j initialize




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
	# Platform 12
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 11 		# $a3 stores y-value
	addi $a1, $zero, 42		# $a1 stores start index
	addi $a2, $zero, 51		# $a2 stores end index
	jal drawLine
	# Platform 13
	li $a0, BROWN			# $a0 stores the colour code
	addi $a3, $zero, 6 		# $a3 stores y-value
	addi $a1, $zero, 0		# $a1 stores start index
	addi $a2, $zero, 9		# $a2 stores end index
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
	addi $a2, $zero, 7		# $a2 stores end index
	jal drawLine
	# Button
	li $a0, BUTTONRED		# $a0 stores the colour code
	addi $a3, $zero, 4 		# $a3 stores y-value
	addi $a1, $zero, 2		# $a1 stores start index
	addi $a2, $zero, 6		# $a2 stores end index
	jal drawLine
	# Barrier 
	li $a0, BARRIERBROWN		# $a0 stores the colour code
	sw $a0, 36($t0)			# Paint colour
	sw $a0, 292($t0)			# Paint colour
	sw $a0, 548($t0)			# Paint colour
	sw $a0, 804($t0)			# Paint colour
	sw $a0, 1060($t0)		# Paint colour
	sw $a0, 1316($t0)		# Paint colour
	
	
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
	

# Draw a vertical line
drawVertLine:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	move $t1, $a0			# Colour
	move $t2, $a1			# Start y
	move $t3, $a2			# End y
	move $t4, $a3			# x value
	
	sll $t2, $t2, 8			# $t2 = start index * 256
	sll $t3, $t3, 8			# Set $t3 = end index * 256
	sll $t4, $t4, 2			# Multiply x value by 4

drawVertLineLoop:
	add $t5, $t4, $t2		# $t5 = y*256 + x*4		
	add $t6, $t5, $t0		# $t6 = address of pixel + base address
	sw $t1, 0($t6)			# Paint the pixel
	addi $t2, $t2, 256		# Increment index by 256
	ble $t2, $t3, drawVertLineLoop	# Continue loop if i <= end index
	
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	
	
	

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

# This function clears the screen
clearScreen:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	addi $t9, $zero, 63		# Store the max y value
	addi $t7, $zero, 0		# $t7 = index
	
clearScreenLoop:
	bgt $t7, $t9, clearScreenEND	# Loop until index > 63
	# Draw black line
	li $a0, BLACK			# $a0 stores colour code
	addi $a1, $zero, 0		# $a1 stores start index
	addi $a2, $zero, 63		# $a2 stores length	
	addi $a3, $t7, 0			# $a3 stores y-value	
	jal drawLine
	addi $t7, $t7, 1			# Increment index by 1
	j clearScreenLoop		# Loop

clearScreenEND:
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	
	
	
# This function clears the screen up until the score text
clearPartialScreen:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	
	addi $t9, $zero, 56		# Store the max y value
	addi $t7, $zero, 0		# $t7 = index
	
clearPartialScreenLoop:
	bgt $t7, $t9, clearPartialScreenEND	# Loop until index > 63
	# Draw black line
	li $a0, BLACK			# $a0 stores colour code
	addi $a1, $zero, 0		# $a1 stores start index
	addi $a2, $zero, 63		# $a2 stores length	
	addi $a3, $t7, 0			# $a3 stores y-value	
	jal drawLine
	addi $t7, $t7, 1			# Increment index by 1
	j clearPartialScreenLoop		# Loop

clearPartialScreenEND:
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	

		
# Draw the restart text
drawRestartText:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack

	# "p" 
	move $t1, $a0			# Get colour of p
	sw $t1, 8272($t0)		# Paint pixel
	sw $t1, 8276($t0)		# Paint pixel
	sw $t1, 8280($t0)		# Paint pixel
	sw $t1, 8528($t0)		# Paint pixel
	sw $t1, 8540($t0)		# Paint pixel
	sw $t1, 8784($t0)		# Paint pixel
	sw $t1, 8788($t0)		# Paint pixel
	sw $t1, 8792($t0)		# Paint pixel
	sw $t1, 9040($t0)		# Paint pixel
	sw $t1, 9296($t0)		# Paint pixel
	
	# Quotes
	li $t1, 	WHITE			# Load colour
	sw $t1, 8004($t0)		# Paint pixel
	sw $t1, 8264($t0)		# Paint pixel
	sw $t1, 8032($t0)		# Paint pixel
	sw $t1, 8292($t0)		# Paint pixel
	
	# "to"
	sw $t1, 8060($t0)		# Paint pixel
	sw $t1, 8316($t0)		# Paint pixel
	sw $t1, 8572($t0)		# Paint pixel
	sw $t1, 8568($t0)		# Paint pixel
	sw $t1, 8576($t0)		# Paint pixel
	sw $t1, 8828($t0)		# Paint pixel
	sw $t1, 9084($t0)		# Paint pixel
	sw $t1, 9340($t0)		# Paint pixel
	sw $t1, 8588($t0)		# Paint pixel
	sw $t1, 8592($t0)		# Paint pixel
	sw $t1, 8840($t0)		# Paint pixel
	sw $t1, 9096($t0)		# Paint pixel
	sw $t1, 9356($t0)		# Paint pixel
	sw $t1, 9360($t0)		# Paint pixel
	sw $t1, 8852($t0)		# Paint pixel
	sw $t1, 9108($t0)		# Paint pixel

	# Arrow 
	sw $t1, 8360($t0)		# Paint pixel
	sw $t1, 8616($t0)		# Paint pixel
	sw $t1, 8872($t0)		# Paint pixel
	sw $t1, 8108($t0)		# Paint pixel
	sw $t1, 8112($t0)		# Paint pixel
	sw $t1, 8116($t0)		# Paint pixel
	sw $t1, 8120($t0)		# Paint pixel
	sw $t1, 8124($t0)		# Paint pixel
	sw $t1, 8128($t0)		# Paint pixel
	sw $t1, 8388($t0)		# Paint pixel
	sw $t1, 8644($t0)		# Paint pixel
	sw $t1, 8900($t0)		# Paint pixel
	sw $t1, 9156($t0)		# Paint pixel
	sw $t1, 9412($t0)		# Paint pixel
	sw $t1, 9668($t0)		# Paint pixel
	sw $t1, 9664($t0)		# Paint pixel
	sw $t1, 9660($t0)		# Paint pixel
	sw $t1, 9656($t0)		# Paint pixel
	sw $t1, 9652($t0)		# Paint pixel
	sw $t1, 9648($t0)		# Paint pixel
	sw $t1, 9912($t0)		# Paint pixel
	sw $t1, 10168($t0)		# Paint pixel
	sw $t1, 9400($t0)		# Paint pixel
	sw $t1, 9144($t0)		# Paint pixel
	sw $t1, 9908($t0)		# Paint pixel
	sw $t1, 9396($t0)		# Paint pixel
	
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra
	

# Draw the "You" text
drawYou:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	move $t9, $a0			# Get colour of text
	move $t2, $t9
	
	# White text
	# Y
	li $t1, WHITE			# Load colour
	sw $t1, 2092($t0)		# Paint pixel
	sw $t1, 2348($t0)		# Paint pixel
	sw $t1, 2604($t0)		# Paint pixel
	sw $t1, 2108($t0)		# Paint pixel
	sw $t1, 2364($t0)		# Paint pixel
	sw $t1, 2620($t0)		# Paint pixel
	sw $t1, 2864($t0)		# Paint pixel
	sw $t1, 2872($t0)		# Paint pixel
	sw $t1, 3124($t0)		# Paint pixel
	sw $t1, 3380($t0)		# Paint pixel
	sw $t1, 3636($t0)		# Paint pixel
	sw $t2, 2088($t0)		# Paint pixel
	sw $t2, 2344($t0)		# Paint pixel
	sw $t2, 2600($t0)		# Paint pixel
	sw $t2, 2104($t0)		# Paint pixel
	sw $t2, 2360($t0)		# Paint pixel
	sw $t2, 2616($t0)		# Paint pixel
	sw $t2, 2860($t0)		# Paint pixel
	sw $t2, 2868($t0)		# Paint pixel
	sw $t2, 3120($t0)		# Paint pixel
	sw $t2, 3376($t0)		# Paint pixel
	sw $t2, 3632($t0)		# Paint pixel
	
	# O
	sw $t2, 2120($t0)		# Paint pixel
	sw $t1, 2124($t0)		# Paint pixel
	sw $t1, 2128($t0)		# Paint pixel
	sw $t1, 2132($t0)		# Paint pixel
	sw $t2, 3656($t0)		# Paint pixel
	sw $t1, 3660($t0)		# Paint pixel
	sw $t1, 3664($t0)		# Paint pixel
	sw $t1, 3668($t0)		# Paint pixel
	
	move $a0, $t9			# Set colour
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 17		# Set x value
	jal drawVertLine
	li $a0, WHITE			# Set colour
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 18		# Set x value
	jal drawVertLine
	move $a0, $t9			# Set colour
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 21		# Set x value
	jal drawVertLine
	li $a0, WHITE			# Set colour
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 22		# Set x value
	jal drawVertLine
	
	
	# U
	move $a0, $t9			# Set colour
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 24		# Set x value
	jal drawVertLine
	li $a0, WHITE			# Set colour
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 25		# Set x value
	jal drawVertLine
	move $a0, $t9			# Set colour
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 28		# Set x value
	jal drawVertLine
	li $a0, WHITE			# Set colour
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 29		# Set x value
	jal drawVertLine
	
	li $t1, WHITE
	move $t2, $t9			
	sw $t2, 3684($t0)		# Paint pixel
	sw $t1, 3688($t0)		# Paint pixel
	sw $t1, 3692($t0)		# Paint pixel
	sw $t1, 3696($t0)		# Paint pixel
	
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	
		

# Draw the lose text
drawLose:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack
	li $a0, LOSERED			# Load colour
	
	# L
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 35		# Set x value
	jal drawVertLine
	li $a0, WHITE			# Load colour
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 36		# Set x value
	jal drawVertLine
	li $t1, LOSERED	
	sw $t1, 3728($t0)		# Paint pixel
	li $t1, WHITE
	sw $t1, 3732($t0)		# Paint pixel
	sw $t1, 3736($t0)		# Paint pixel
	sw $t1, 3740($t0)		# Paint pixel
	
	# O
	li $t1, LOSERED	
	sw $t1, 2212($t0)		# Paint pixel
	sw $t1, 3748($t0)		# Paint pixel
	li $t1, WHITE
	sw $t1, 2216($t0)		# Paint pixel
	sw $t1, 2220($t0)		# Paint pixel
	sw $t1, 2224($t0)		# Paint pixel
	sw $t1, 3752($t0)		# Paint pixel
	sw $t1, 3756($t0)		# Paint pixel
	sw $t1, 3760($t0)		# Paint pixel
	li $a0, LOSERED
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 40		# Set x value
	jal drawVertLine
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 44		# Set x value
	jal drawVertLine
	li $a0, WHITE
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 41		# Set x value
	jal drawVertLine
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 45		# Set x value
	jal drawVertLine
	
	# S
	li $t1, LOSERED
	sw $t1, 2240($t0)		# Paint pixel
	sw $t1, 2492($t0)		# Paint pixel
	sw $t1, 2748($t0)		# Paint pixel
	sw $t1, 3008($t0)		# Paint pixel
	sw $t1, 3268($t0)		# Paint pixel
	sw $t1, 3272($t0)		# Paint pixel
	sw $t1, 3276($t0)		# Paint pixel
	sw $t1, 3532($t0)		# Paint pixel
	sw $t1, 3772($t0)		# Paint pixel
	li $a0, WHITE
	addi $a1, $zero, 49		# Set start x
	addi $a2, $zero, 52		# Set end x
	addi $a3, $zero, 8		# Set y value
	jal drawLine
	addi $a1, $zero, 49		# Set start x
	addi $a2, $zero, 51		# Set end x
	addi $a3, $zero, 11		# Set y value
	jal drawLine
	addi $a1, $zero, 48		# Set start x
	addi $a2, $zero, 51		# Set end x
	addi $a3, $zero, 14		# Set y value
	jal drawLine
	li $t1, WHITE
	sw $t1, 2496($t0)		# Paint pixel
	sw $t1, 2752($t0)		# Paint pixel
	sw $t1, 3280($t0)		# Paint pixel
	sw $t1, 3536($t0)		# Paint pixel
	
	# E
	li $t1, LOSERED
	sw $t1, 2268($t0)		# Paint pixel
	sw $t1, 3804($t0)		# Paint pixel
	li $a0, LOSERED
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 54		# Set x value
	jal drawVertLine
	li $a0, WHITE
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 55		# Set x value
	jal drawVertLine
	addi $a1, $zero, 56		# Set start x
	addi $a2, $zero, 59		# Set end x
	addi $a3, $zero, 8		# Set y value
	jal drawLine
	addi $a1, $zero, 56		# Set start x
	addi $a2, $zero, 58		# Set end x
	addi $a3, $zero, 11		# Set y value
	jal drawLine
	addi $a1, $zero, 56		# Set start x
	addi $a2, $zero, 59		# Set end x
	addi $a3, $zero, 14		# Set y value
	jal drawLine
	
	
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	
	

# This function draws the "win" text
drawWin:
	# Store $ra	
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack

	# W
	li $a0, WINGREEN
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 35		# Set x value
	jal drawVertLine
	li $a0, WHITE			# Set colour
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 36		# Set x value
	jal drawVertLine
	li $a0, WINGREEN
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 39		# Set x value
	jal drawVertLine
	li $a0, WHITE			# Set colour
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 13		# Set end y
	addi $a3, $zero, 40		# Set x value
	jal drawVertLine

	li $t1, WINGREEN
	sw $t1, 3728($t0)		# Paint pixel
	li $t1, WHITE
	sw $t1, 3732($t0)		# Paint pixel
	sw $t1, 3740($t0)		# Paint pixel
	sw $t1, 3480($t0)		# Paint pixel
	sw $t1, 3224($t0)		# Paint pixel

	# I
	li $a0, WINGREEN
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 9		# Set end y
	addi $a3, $zero, 42		# Set x value
	jal drawVertLine
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 14		# Set end y
	addi $a3, $zero, 43		# Set x value
	jal drawVertLine
	li $a0, WINGREEN
	addi $a1, $zero, 13		# Set start y
	addi $a2, $zero, 14		# Set end y
	addi $a3, $zero, 42		# Set x value
	jal drawVertLine
	li $a0, WHITE
	addi $a1, $zero, 9		# Set start y
	addi $a2, $zero, 14		# Set end y
	addi $a3, $zero, 44		# Set x value
	jal drawVertLine
	addi $a1, $zero, 43		# Set start x
	addi $a2, $zero, 45		# Set end x
	addi $a3, $zero, 8		# Set y value
	jal drawLine
	addi $a1, $zero, 43		# Set start x
	addi $a2, $zero, 45		# Set end x
	addi $a3, $zero, 14		# Set y value
	jal drawLine
	
	# N
	li $a0, WINGREEN
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 14		# Set end y
	addi $a3, $zero, 47		# Set x value
	jal drawVertLine
	addi $a1, $zero, 10		# Set start y
	addi $a2, $zero, 12		# Set end y
	addi $a3, $zero, 49		# Set x value
	jal drawVertLine
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 14		# Set end y
	addi $a3, $zero, 51		# Set x value
	jal drawVertLine
	li $a0, WHITE
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 14		# Set end y
	addi $a3, $zero, 48		# Set x value
	jal drawVertLine
	addi $a1, $zero, 10		# Set start y
	addi $a2, $zero, 12		# Set end y
	addi $a3, $zero, 50		# Set x value
	jal drawVertLine
	addi $a1, $zero, 8		# Set start y
	addi $a2, $zero, 14		# Set end y
	addi $a3, $zero, 52		# Set x value
	jal drawVertLine
	li $t1, WHITE
	sw $t1, 2500($t0)		# Paint pixel
	sw $t1, 3532($t0)		# Paint pixel
	li $t1, WINGREEN
	sw $t1, 3528($t0)		# Paint pixel

	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	

	
# This function clears the registers
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
	move $s0, $0			# Clear register
	move $s1, $0			# Clear register
	move $s2, $0			# Clear register
	move $s3, $0			# Clear register
	move $s4, $0			# Clear register
	move $s5, $0			# Clear register
	move $s6, $0			# Clear register
	move $s7, $0			# Clear register
	
	# Restore $ra
	lw $ra, 0($sp)			# Restore $ra
	addi $sp, $sp, 4			# Prepare stack address
	jr $ra	

	
