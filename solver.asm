#  Minesweeper
#
#  Your Name: Jeremy Gibson	
#  Date: 10/12/2018

### Approach: This code iterates left to right then top to bottom around the board making moves
### when logical. If a move cannot be logically made after iterating through the board, the next
### open square is guessed. There are two types of logical moves that the code acknowledges. When
### the number of flags surrounding a square is equal to the square's number, the remaining unopened
### surrounding squares can be confidently opened. When the number of remaining unopened surrounding
### squares is equal to the number of flags that still need to be places around a square, flags can
### confidently be placed in each of those surrounding squares. Throughout the code, an array stored
### in memory is used to keep track of whether a square is unopened, flagged, or holding a value.


.data
# Initialize Array of 10's (10 in each byte) denoting unopened squares
A:  .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090
    .word 168430090

### RESGISTERS USED ###
# R1: Number of Unmarked Mines
# R2: Position Index
# R3: Operation Number / Position Value for Counter
#		-1: Guess
#		 0: Open
#		 1: Flag
# R4: Return Value
#		 -1: Mine
#		0-8: Count
#		  9: Flag
# R5: Position Value
# R6: Iterations w/o move
# R7: Conditional
# R8: Constant 8
# R9: Conditional
# R10: Constant 10
# R11: Conditional
# R12: Return Address Holder
# R13: Surrounding count
# R14: Flag count
# R15: Func
# R16: Return Address Holder
# R17: Constant 11
# R18: Constant 9
# R20: Constant -1
# R21: Position Index Holder
# R22: Conditional

.text
MineSweep: swi 567 # Bury mines (returns # of mines buried in R1)
j Init

### Helper Funcctions ###
Reg: jr $15							# Directs to specified function

# Open or Flag Function
OoFer:    lbu $5, A($2)				# Loads indexed value
          bne $5, $10, Return1		# Return to Opps if value is known already
          beq $3, $0, Op 
          addi $1, $1, -1			# If setting a flag, subtract 1 from unmarked mine counter
Op:		    swi 568					# Perform operation
		      sb $4, A($2)				# Store returned value in array
		      addi $6, $0, 0				# Reset counter used for guessing
Return1:  jr $31						# Return to Opps

Counter:  lbu $3, A($2)				# Load indexed value
          bne $3, $10, Nines
          addi $13, $13, 1			# Add 1 to flag count if flag
Nines:    bne $3, $18, Return2
          addi $14, $14, 1			# Add 1 to unopened count if unopened
Return2:  jr $31

# Initialize Values
Init:	addi $2, $0, 0
      addi $6, $0, 65				# Start guess counter over limit so first move is guess
      addi $8, $0, 8
      addi $10, $0, 10
      addi $17, $0, 11
      addi $18, $0, 9
      addi $20, $0, -1
      addi $12, $31, 0

### Solver Loop ###
Solver:	  lbu $5, A($2)				# Load indexed value
          beq $5, $17, Index 			# Skip if square is already surrounded
          beq $5, $18, Index 			# Skip if square is flagged
Guess:  	slti $7, $6, 65
          bne $7, $0, Get				# Only guess after all board values have been analyzed
          bne $5, $10, Get			# Don't guess if value is already known
          addi $3, $0, -1
          swi 568						# Guess indexed value
          addi $5, $4, 0
          bne $4, $20, NotFlag
          addi $5, $0, 9
          addi $1, $1, -1
NotFlag:  sb $5, A($2)				# Update array with new value
          addi $6, $0, 0				# Reset counter used for guessing

Get:	beq $5, $10, Index 			# Only analyze surrounding if value is known
      addi $13, $0, 0				# Reset unopened counter
      addi $14, $0, 0				# Reset flags counter
      addi $15, $0, Counter 		# Specify counter operation
      jal Opps					# Go to Opps
		
Flags:	sub $7, $5, $14
        bne $7, $13, Opens			# Set flags if logical
        addi $15, $0, OoFer			# Specify Open/Flagging operation
        sb $17, A($2)				# Mark square as surrounded
        addi $3, $0, 1				# Specify flag operation
        jal Opps					# Go to Opps
		
Opens:	bne $5, $14, Index 			# Open surroudning if logical
        addi $15, $0, OoFer			# Specify Open/Flagging operation
        sb $17, A($2)				# Mark square as surrounded
        addi $3, $0, 0				# Specify open operation
        jal Opps					# Go to Opps

Index:	addi $6, $6, 1				# Increment guessing counter
        addi $2, $2, 1				# Increment position index
        slti $7, $2, 64
        bne $7, $0, JBack
        addi $2, $0, 0

JBack:	bne $1, $0, Solver			# Next iteration of solver loop if game isn't over

GameOver:	addi $31, $12, 0
          jr $31					# Return to OS

# Opps function is used to conduct various operations/analysis on surrounding squares after checking if they exist
Opps:	addi $16, $31, 0
      addi $21, $2, 0
      slti $7, $2, 8				# R7 = 1 if NO NORTH
      slti $9, $2, 56				# R9 = 0 if NO SOUTH
      div $2, $8
      mfhi $11					# R11 = 0 if NO WEST
      addi $2, $21, 1
      div $2, $8
      mfhi $22					# R22 = 0 if NO EAST

NW:	 	bne $7, $0, W
      addi $2, $21, -9
      beq $11, $0, S
      jal Reg

W:		beq $11, $0, S
      addi $2, $21, -1
      jal Reg

SW:	 	beq $9, $0, E
      beq $11, $0, S
      addi $2, $21, 7
      jal Reg

S:		beq $9, $0, E
      addi $2, $21, 8
      jal Reg

SE:		beq $9, $0, E
      beq $22, $0, N
      addi $2, $21, 9
      jal Reg

E:		beq $22, $0, N
      addi $2, $21, 1
      jal Reg

NE:	 	bne $7, $0, End
      beq $22, $0, N
      addi $2, $21, -7
      jal Reg

N:		bne $7, $0, End
      addi $2, $21, -8
      jal Reg

End:	addi $2, $21, 0
      addi  $31, $16, 0
      jr $31
