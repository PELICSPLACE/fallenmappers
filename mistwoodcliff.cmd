#### START SCRIPT
	action var Dir $1 when ^Peering closely at a faint path\, you realize you would need to head (\w+)\.
	send peer path
	waitforre Peering closely at
	send down
	send %Dir
	send northwest
	waitforre ^Birds chitter in the branches
	put #parse MOVE SUCCESSFUL
	put #parse MOVE SUCCESSFUL
#### END OF SCRIPT