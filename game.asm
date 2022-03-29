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
 
 .eqv	COINYELLOW 0xffc107
 .eqv	COINBLUE 0x40a4f5
 
 .eqv	HAIRWHITE 0xf5f5f5
 .eqv	LEFTEYE 0x3e2723
 .eqv	RIGHTEYE  0xd50000
 .eqv	SKINPEACH 0xfce8db
	
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
	# Platform 5
	li $a0, STOPPEDORANGE		# $a0 stores the colour code
	addi $a3, $zero, 33 		# $a3 stores y-value
	addi $a1, $zero, 20		# $a1 stores start index
	addi $a2, $zero, 27		# $a2 stores end index
	jal drawLine
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
	addi $a2, $zero, 48		# Set x value
	addi $a3, $zero, 44		# Set y value
	jal drawCoin
	# Coin 2
	addi $a2, $zero, 12		# Set x value
	addi $a3, $zero, 41		# Set y value
	jal drawCoin
	# Coin 3
	addi $a2, $zero, 35		# Set x value
	addi $a3, $zero, 26		# Set y value
	jal drawCoin
	# Coin 4
	addi $a2, $zero, 60		# Set x value
	addi $a3, $zero, 22		# Set y value
	jal drawCoin
	# Coin 5
	addi $a2, $zero, 45		# Set x value
	addi $a3, $zero, 6		# Set y value
	jal drawCoin
	# Coin 6
	addi $a2, $zero, 15		# Set x value
	addi $a3, $zero, 1		# Set y value
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
	addi $sp, $sp, -4		# Update stack address
	sw $ra, 0($sp)			# Push $ra to the stack	
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
		
	jr $ra				# Return to line that called function
	
	
				
#-----------------------------------------Draw Pickup Function-----------------------------					
drawPickup:
# $a0 = determines which colour pickup to draw ( PPBLUE1 = blue, PPGREEN1 = green, PPVIOLET1 = purple )
# $a1 = start index
# $a2 = end index
# $a3 = y value

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
	
	







