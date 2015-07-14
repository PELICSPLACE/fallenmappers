#### Find the stupid path to Sorrow's Reach
SorrowsReach:
     # debuglevel 10
Checkroom:
     pause 0.5
     if matchre("$roomobjs", "a small overgrown path") then goto SorrowsReachMoveOn
     else goto Search
Search:
     matchre Search ^\.\.\.wait|^Sorry\,
     matchre SorrowsReachMoveOn ^There seems to be some sort of path leading to the east\.
     matchre Checkroom ^You search around for a moment\.
     send search
     matchwait
SorrowsReachMoveOn:
     send go path
     waitforre ^The path underfoot is overgrown with weeds and almost completely covered with dried\, fallen branches yet still feels surprisingly firm\.
     pause
     put #parse MOVE SUCCESSFUL
     exit
#### EOF