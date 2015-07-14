#debug 10
#---------------------------------------
# INCLUDES
#---------------------------------------
goto SubSkip
#---------------------------------------
# Local Subroutines
#---------------------------------------

SubSkip:

#---------------------------------------
# CONSTANT VARIABLES
#---------------------------------------

#---------------------------------------
# VARIABLES
#---------------------------------------

#---------------------------------------
# ACTIONS
#---------------------------------------
	action var Dir $1 when ^Peering closely at a faint path, you realize you would need to head (\w+)\.
#---------------------------------------
# SCRIPT START
#---------------------------------------
	send peer path
	waitforre Peering closely at
	send down
	send %Dir
	send northwest
	waitforre ^Birds chitter in the branches
	pause 0.5
	put #parse MOVE SUCCESSFUL
	