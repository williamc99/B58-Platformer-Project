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
	
.eqv	HEIGHT 64
.eqv	WIDTH 64
.eqv	MAX_X 252
	
.eqv	scoreLineY 56
.eqv 	waterLine1 55
.eqv	waterLine2 54

.data
.text
drawStart:
	li $t0, BASE_ADDRESS		# $t0 stores the base address for display
	
	#---------------------------------Draw Water---------------------------------------
	# Draw water line 1
	li $t1, WATERBLUE		# $t1 stores the white colour code
	addi $t4, $zero, waterLine1	# $t4 stores y-value
	addi $t2, $zero, 0		# $t2 stores start index
	addi $t3, $zero, 63		# $t3 stores length		
	jal drawLine
	# Draw water line 2
	li $t1, WATERBLUE		# $t1 stores the white colour code
	addi $t4, $zero, waterLine2	# $t4 stores y-value
	addi $t2, $zero, 0		# $t2 stores start index
	addi $t3, $zero, 63		# $t3 stores length		
	jal drawLine
	
	#---------------------------------Draw Score---------------------------------------
	# Draw white line for score
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, scoreLineY	# $t4 stores y-value
	addi $t2, $zero, 0		# $t2 stores start index
	addi $t3, $zero, 63		# $t3 stores end index
	jal drawLine
	# Draw 5 Lines for Score Text
	# Draw white line for score
	# Line 1
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 58		# $t4 stores y-value
	addi $t2, $zero, 10		# $t2 stores start index
	addi $t3, $zero, 33		# $t3 stores end index
	jal drawLine
	# Line 2
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 59		# $t4 stores y-value
	addi $t2, $zero, 10		# $t2 stores start index
	addi $t3, $zero, 33		# $t3 stores end index
	jal drawLine
	# Line 3
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 60		# $t4 stores y-value
	addi $t2, $zero, 10		# $t2 stores start index
	addi $t3, $zero, 33		# $t3 stores end index
	jal drawLine
	# Line 4
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 61		# $t4 stores y-value
	addi $t2, $zero, 10		# $t2 stores start index
	addi $t3, $zero, 33		# $t3 stores end index
	jal drawLine
	# Line 5
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 62		# $t4 stores y-value
	addi $t2, $zero, 10		# $t2 stores start index
	addi $t3, $zero, 33		# $t3 stores end index
	jal drawLine
	# Chiesel Details
	# First Row
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 58 		# $t4 stores y-value
	addi $t2, $zero, 10		# $t2 stores start index
	addi $t3, $zero, 10		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 58 		# $t4 stores y-value
	addi $t2, $zero, 14		# $t2 stores start index
	addi $t3, $zero, 15		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 58 		# $t4 stores y-value
	addi $t2, $zero, 19		# $t2 stores start index
	addi $t3, $zero, 20		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 58 		# $t4 stores y-value
	addi $t2, $zero, 23		# $t2 stores start index
	addi $t3, $zero, 24		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 58 		# $t4 stores y-value
	addi $t2, $zero, 28		# $t2 stores start index
	addi $t3, $zero, 30		# $t3 stores end index
	jal drawLine
	# Second Row
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 59 		# $t4 stores y-value
	addi $t2, $zero, 11		# $t2 stores start index
	addi $t3, $zero, 14		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 59 		# $t4 stores y-value
	addi $t2, $zero, 16		# $t2 stores start index
	addi $t3, $zero, 19		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 59 		# $t4 stores y-value
	addi $t2, $zero, 21		# $t2 stores start index
	addi $t3, $zero, 22		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 59 		# $t4 stores y-value
	addi $t2, $zero, 24		# $t2 stores start index
	addi $t3, $zero, 24		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 59 		# $t4 stores y-value
	addi $t2, $zero, 26		# $t2 stores start index
	addi $t3, $zero, 27		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 59 		# $t4 stores y-value
	addi $t2, $zero, 29		# $t2 stores start index
	addi $t3, $zero, 29		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 59 		# $t4 stores y-value
	addi $t2, $zero, 31		# $t2 stores start index
	addi $t3, $zero, 33		# $t3 stores end index
	jal drawLine
	# Third Row
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 60 		# $t4 stores y-value
	addi $t2, $zero, 14		# $t2 stores start index
	addi $t3, $zero, 14		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 60 		# $t4 stores y-value
	addi $t2, $zero, 16		# $t2 stores start index
	addi $t3, $zero, 19		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 60 		# $t4 stores y-value
	addi $t2, $zero, 21		# $t2 stores start index
	addi $t3, $zero, 22		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 60 		# $t4 stores y-value
	addi $t2, $zero, 24		# $t2 stores start index
	addi $t3, $zero, 24		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 60 		# $t4 stores y-value
	addi $t2, $zero, 28		# $t2 stores start index
	addi $t3, $zero, 29		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 60 		# $t4 stores y-value
	addi $t2, $zero, 33		# $t2 stores start index
	addi $t3, $zero, 33		# $t3 stores end index
	jal drawLine
	# Fourth Row
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 61 		# $t4 stores y-value
	addi $t2, $zero, 10		# $t2 stores start index
	addi $t3, $zero, 12		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 61 		# $t4 stores y-value
	addi $t2, $zero, 14		# $t2 stores start index
	addi $t3, $zero, 14		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 61 		# $t4 stores y-value
	addi $t2, $zero, 16		# $t2 stores start index
	addi $t3, $zero, 19		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 61 		# $t4 stores y-value
	addi $t2, $zero, 21		# $t2 stores start index
	addi $t3, $zero, 22		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 61 		# $t4 stores y-value
	addi $t2, $zero, 24		# $t2 stores start index
	addi $t3, $zero, 24		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 61 		# $t4 stores y-value
	addi $t2, $zero, 26		# $t2 stores start index
	addi $t3, $zero, 26		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 61 		# $t4 stores y-value
	addi $t2, $zero, 28		# $t2 stores start index
	addi $t3, $zero, 29		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 61 		# $t4 stores y-value
	addi $t2, $zero, 31		# $t2 stores start index
	addi $t3, $zero, 33		# $t3 stores end index
	jal drawLine
	# Fifth Row
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 62 		# $t4 stores y-value
	addi $t2, $zero, 13		# $t2 stores start index
	addi $t3, $zero, 15		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 62 		# $t4 stores y-value
	addi $t2, $zero, 19		# $t2 stores start index
	addi $t3, $zero, 20		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 62 		# $t4 stores y-value
	addi $t2, $zero, 23		# $t2 stores start index
	addi $t3, $zero, 24		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 62 		# $t4 stores y-value
	addi $t2, $zero, 26		# $t2 stores start index
	addi $t3, $zero, 27		# $t3 stores end index
	jal drawLine
	li $t1, BLACK			# $t1 stores the black colour code
	addi $t4, $zero, 62 		# $t4 stores y-value
	addi $t2, $zero, 29		# $t2 stores start index
	addi $t3, $zero, 30		# $t3 stores end index
	jal drawLine
	# Draw Colons
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 59 		# $t4 stores y-value
	addi $t2, $zero, 36		# $t2 stores start index
	addi $t3, $zero, 36		# $t3 stores end index
	jal drawLine
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 61 		# $t4 stores y-value
	addi $t2, $zero, 36		# $t2 stores start index
	addi $t3, $zero, 36		# $t3 stores end index
	jal drawLine
	
	#---------------------------------Draw Score Numbers-------------------------------
	# Draw Zeroes
	# Row 1
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 58 		# $t4 stores y-value
	addi $t2, $zero, 42		# $t2 stores start index
	addi $t3, $zero, 43		# $t3 stores end index
	jal drawLine
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 58 		# $t4 stores y-value
	addi $t2, $zero, 47		# $t2 stores start index
	addi $t3, $zero, 48		# $t3 stores end index
	jal drawLine
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 58 		# $t4 stores y-value
	addi $t2, $zero, 52		# $t2 stores start index
	addi $t3, $zero, 53		# $t3 stores end index
	jal drawLine
	# Row 2
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 62 		# $t4 stores y-value
	addi $t2, $zero, 42		# $t2 stores start index
	addi $t3, $zero, 43		# $t3 stores end index
	jal drawLine
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 62 		# $t4 stores y-value
	addi $t2, $zero, 47		# $t2 stores start index
	addi $t3, $zero, 48		# $t3 stores end index
	jal drawLine
	li $t1, WHITE			# $t1 stores the white colour code
	addi $t4, $zero, 62 		# $t4 stores y-value
	addi $t2, $zero, 52		# $t2 stores start index
	addi $t3, $zero, 53		# $t3 stores end index
	jal drawLine
	li $t1, WHITE			# $t1 stores the white colour code
	# Coloumn 1
	sw $t1, 15268($t0)		# Paint pixel white
	sw $t1, 15524($t0)		# Paint pixel white
	sw $t1, 15780($t0)		# Paint pixel white
	# Coloumn 2
	sw $t1, 15280($t0)		# Paint pixel white
	sw $t1, 15536($t0)		# Paint pixel white
	sw $t1, 15792($t0)		# Paint pixel white
	# Coloumn 3
	sw $t1, 15288($t0)		# Paint pixel white
	sw $t1, 15544($t0)		# Paint pixel white
	sw $t1, 15800($t0)		# Paint pixel white
	# Coloumn 4
	sw $t1, 15300($t0)		# Paint pixel white
	sw $t1, 15556($t0)		# Paint pixel white
	sw $t1, 15812($t0)		# Paint pixel white
	# Coloumn 5
	sw $t1, 15308($t0)		# Paint pixel white
	sw $t1, 15564($t0)		# Paint pixel white
	sw $t1, 15820($t0)		# Paint pixel white
	# Coloumn 6
	sw $t1, 15320($t0)		# Paint pixel white
	sw $t1, 15576($t0)		# Paint pixel white
	sw $t1, 15832($t0)		# Paint pixel white
		
		
	#---------------------------------Draw Static Platforms----------------------------
	# Platforms are numbered from bottom to top, left to right
	# Platform 1 (starting platform)
	li $t1, BROWN			# $t1 stores the colour code
	addi $t4, $zero, 49 		# $t4 stores y-value
	addi $t2, $zero, 0		# $t2 stores start index
	addi $t3, $zero, 9		# $t3 stores end index
	jal drawLine
	# Platform 2
	li $t1, BROWN			# $t1 stores the colour code
	addi $t4, $zero, 45 		# $t4 stores y-value
	addi $t2, $zero, 19		# $t2 stores start index
	addi $t3, $zero, 27		# $t3 stores end index
	jal drawLine
	# Platform 3
	li $t1, BROWN			# $t1 stores the colour code
	addi $t4, $zero, 40 		# $t4 stores y-value
	addi $t2, $zero, 33		# $t2 stores start index
	addi $t3, $zero, 42		# $t3 stores end index
	jal drawLine
	# Platform 4
	li $t1, BROWN			# $t1 stores the colour code
	addi $t4, $zero, 40 		# $t4 stores y-value
	addi $t2, $zero, 60		# $t2 stores start index
	addi $t3, $zero, 63		# $t3 stores end index
	jal drawLine
	# Platform 7
	li $t1, BROWN			# $t1 stores the colour code
	addi $t4, $zero, 27 		# $t4 stores y-value
	addi $t2, $zero, 7		# $t2 stores start index
	addi $t3, $zero, 15		# $t3 stores end index
	jal drawLine
	# Platform 8
	li $t1, BROWN			# $t1 stores the colour code
	addi $t4, $zero, 27 		# $t4 stores y-value
	addi $t2, $zero, 60		# $t2 stores start index
	addi $t3, $zero, 63		# $t3 stores end index
	jal drawLine
	# Platform 9
	li $t1, BROWN			# $t1 stores the colour code
	addi $t4, $zero, 21 		# $t4 stores y-value
	addi $t2, $zero, 0		# $t2 stores start index
	addi $t3, $zero, 3		# $t3 stores end index
	jal drawLine
	# Platform 11
	li $t1, BROWN			# $t1 stores the colour code
	addi $t4, $zero, 17 		# $t4 stores y-value
	addi $t2, $zero, 25		# $t2 stores start index
	addi $t3, $zero, 35		# $t3 stores end index
	jal drawLine
	# Platform 13
	li $t1, BROWN			# $t1 stores the colour code
	addi $t4, $zero, 6 		# $t4 stores y-value
	addi $t2, $zero, 0		# $t2 stores start index
	addi $t3, $zero, 8		# $t3 stores end index
	jal drawLine
	# Platform 14
	li $t1, BROWN			# $t1 stores the colour code
	addi $t4, $zero, 6 		# $t4 stores y-value
	addi $t2, $zero, 60		# $t2 stores start index
	addi $t3, $zero, 63		# $t3 stores end index
	jal drawLine
		
	
	#---------------------------------Draw Button--------------------------------------
	# Button Base
	li $t1, BUTTONGRAY		# $t1 stores the colour code
	addi $t4, $zero, 5 		# $t4 stores y-value
	addi $t2, $zero, 1		# $t2 stores start index
	addi $t3, $zero, 6		# $t3 stores end index
	jal drawLine
	# Button
	li $t1, BUTTONRED		# $t1 stores the colour code
	addi $t4, $zero, 4 		# $t4 stores y-value
	addi $t2, $zero, 2		# $t2 stores start index
	addi $t3, $zero, 5		# $t3 stores end index
	jal drawLine
	# Barrier
	li $t1, BARRIERBROWN		# $t1 stores the colour code
	sw $t1, 32($t0)			# Paint colour
	sw $t1, 288($t0)			# Paint colour
	sw $t1, 544($t0)			# Paint colour
	sw $t1, 800($t0)			# Paint colour
	sw $t1, 1056($t0)		# Paint colour
	sw $t1, 1312($t0)		# Paint colour

	#---------------------------------Draw Stopped Platforms---------------------------
	# Platform 5
	li $t1, STOPPEDORANGE		# $t1 stores the colour code
	addi $t4, $zero, 33 		# $t4 stores y-value
	addi $t2, $zero, 20		# $t2 stores start index
	addi $t3, $zero, 27		# $t3 stores end index
	jal drawLine
	# Platform 6
	li $t1, STOPPEDORANGE		# $t1 stores the colour code
	addi $t4, $zero, 33 		# $t4 stores y-value
	addi $t2, $zero, 47		# $t2 stores start index
	addi $t3, $zero, 53		# $t3 stores end index
	jal drawLine
	# Platform 10
	li $t1, STOPPEDORANGE		# $t1 stores the colour code
	addi $t4, $zero, 17 		# $t4 stores y-value
	addi $t2, $zero, 10		# $t2 stores start index
	addi $t3, $zero, 16		# $t3 stores end index
	jal drawLine
	# Platform 12
	li $t1, STOPPEDORANGE		# $t1 stores the colour code
	addi $t4, $zero, 11 		# $t4 stores y-value
	addi $t2, $zero, 42		# $t2 stores start index
	addi $t3, $zero, 51		# $t3 stores end index
	jal drawLine






	#---------------------------------Terminate Program--------------------------------
	li $v0, 10			# Assign syscall
	syscall				# Call syscall
	




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
	sll $t2, $t2, 2			# $t2 = start index * 4
	sll $t3, $t3, 2			# Set $t3 = end index * 4
	sll $t4, $t4, 8			# Multiply y value by 256 to get y*width*4
drawLineLoop:
	add $t5, $t4, $t2		# $t5 = y*width + x		
	add $t6, $t5, $t0		# $t6 = address of pixel + base address
	sw $t1, 0($t6)			# Paint the pixel
	addi $t2, $t2, 4			# Increment index by 4
	ble $t2, $t3, drawLineLoop	# Continue loop if i <= end index
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack	
	jr $ra				# Jump back to line that called us
	
	
	
	
	
	
	
	
clearRegisters:
	# Usage:
		#jal clearRegisters		# Clear registers using function
		#lw $ra, 0($sp)			# Restore $ra
		#addi $sp, $sp, 4			# Prepare stack address
	move $t1, $0			# Clear register
	move $t2, $0			# Clear register
	move $t3, $0			# Clear register
	move $t4, $0			# Clear register
	move $t5, $0			# Clear register
	move $t6, $0			# Clear register
	move $t7, $0			# Clear register
	move $t8, $0			# Clear register
	move $t9, $0			# Clear register
	jr $ra
	
	







