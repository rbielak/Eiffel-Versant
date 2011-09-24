-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class TROOP

inherit
	
	PARRAY [PERSON]
		redefine
			generator
		end
creation
	
	make

feature
	
	generator: STRING is "TROOP"
	
	leader: PERSON
	
	set_leader (new_leader: PERSON) is
		do
			leader := new_leader
		end

invariant

end -- TROOP
