-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Action to take for each element while computing closure
--

class POBJECT_ACTION_COMMAND
	
creation
	
	make

feature {POBJECT, POBJECT_CLOSURE_SCANNER}
	
	execute (closure : TWO_WAY_LIST [POBJECT]; object : POBJECT) is
		do
			closure.extend (object);
			object.set_closure_position (closure.count)
		end
	
	make (root_of_closure : POBJECT) is
		do
			root := root_of_closure
		end
	
	root : POBJECT
			-- the first object from which closure
			-- computation started

end -- POBJECT_ACTION_COMMAD
